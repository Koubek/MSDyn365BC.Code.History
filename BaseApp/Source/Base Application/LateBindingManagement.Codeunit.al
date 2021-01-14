codeunit 6502 "Late Binding Management"
{

    trigger OnRun()
    begin
    end;

    var
        TempCurrSupplyReservEntry: Record "Reservation Entry" temporary;
        TempCurrDemandReservEntry: Record "Reservation Entry" temporary;
        TempSupplyReservEntry: Record "Reservation Entry" temporary;
        TempReservEntryDelete: Record "Reservation Entry" temporary;
        TempReservEntryModify: Record "Reservation Entry" temporary;
        TempReservEntryInsert: Record "Reservation Entry" temporary;
        ReservMgt: Codeunit "Reservation Management";
        LastEntryNo: Integer;
        Text001: Label 'Not enough free supply available for reallocation.';

    local procedure CleanUpVariables()
    begin
        ClearAll;
        TempReservEntryDelete.Reset;
        TempReservEntryDelete.DeleteAll;
        TempReservEntryModify.Reset;
        TempReservEntryModify.DeleteAll;
        TempReservEntryInsert.Reset;
        TempReservEntryInsert.DeleteAll;
        TempCurrSupplyReservEntry.Reset;
        TempCurrSupplyReservEntry.DeleteAll;
        TempCurrDemandReservEntry.Reset;
        TempCurrDemandReservEntry.DeleteAll;
        TempSupplyReservEntry.Reset;
        TempSupplyReservEntry.DeleteAll;
    end;

    procedure ReallocateTrkgSpecification(var TempTrackingSpecification: Record "Tracking Specification" temporary)
    begin
        // Go through the tracking specification and calculate what is available/reserved/can be reallocated
        // The buffer fields on TempTrackingSpecification are used as follows:
        // "Buffer Value1" : Non-allocated item tracking
        // "Buffer Value2" : Total inventory
        // "Buffer Value3" : Total reserved inventory
        // "Buffer Value4" : Qty for reallocation (negative = need for reallocation)
        // "Buffer Value5" : Total non-specific reserved inventory (can be un-reserved through reallocation)

        CleanUpVariables;

        TempTrackingSpecification.CalcSums("Buffer Value1"); // Non-allocated item tracking

        if TempTrackingSpecification."Buffer Value1" = 0 then
            exit; // Item tracking is fully allocated => no basis for reallocation

        if not CalcInventory(TempTrackingSpecification) then
            exit; // No reservations exist => no basis for reallocation

        TempTrackingSpecification.SetFilter("Buffer Value4", '< %1', 0);
        if TempTrackingSpecification.IsEmpty then begin
            TempTrackingSpecification.Reset;
            exit; // Supply is available - no need for reallocation
        end;

        TempTrackingSpecification.Reset;

        // Try to free sufficient supply by reallocation within the tracking specification
        CalcAllocations(TempTrackingSpecification);

        TempTrackingSpecification.Reset;
        TempTrackingSpecification.CalcSums("Buffer Value4");

        if TempTrackingSpecification."Buffer Value4" < 0 then
            if not PrepareTempDataSet(TempTrackingSpecification, Abs(TempTrackingSpecification."Buffer Value4")) then
                exit; // There is not sufficient free supply to cover reallocation

        TempTrackingSpecification.Reset;
        Reallocate(TempTrackingSpecification);

        // Write to database in the end
        WriteToDatabase;
    end;

    local procedure Reallocate(var TempTrackingSpecification: Record "Tracking Specification" temporary) AllocationsChanged: Boolean
    var
        TempTrackingSpecification2: Record "Tracking Specification" temporary;
        QtyToReallocate: Decimal;
    begin
        TempTrackingSpecification.Reset;
        TempTrackingSpecification.SetFilter("Buffer Value4", '< %1', 0);
        if TempTrackingSpecification.FindSet then
            repeat
                TempTrackingSpecification2 := TempTrackingSpecification;
                TempTrackingSpecification2.Insert;
            until TempTrackingSpecification.Next = 0;
        TempTrackingSpecification.Reset;

        TempCurrSupplyReservEntry.Reset;
        if TempTrackingSpecification2.FindSet then
            repeat
                TempCurrSupplyReservEntry.SetTrackingFilter(
                  TempTrackingSpecification2."Serial No.", TempTrackingSpecification2."Lot No.", TempTrackingSpecification2."CD No.");
                QtyToReallocate := Abs(TempTrackingSpecification2."Buffer Value4");
                if TempCurrSupplyReservEntry.FindSet then
                    repeat
                        QtyToReallocate := ReshuffleReservEntry(TempCurrSupplyReservEntry, QtyToReallocate, TempTrackingSpecification);
                    until (TempCurrSupplyReservEntry.Next = 0) or (QtyToReallocate = 0);
                AllocationsChanged := AllocationsChanged or (QtyToReallocate <> Abs(TempTrackingSpecification2."Buffer Value4"));
            until TempTrackingSpecification2.Next = 0;
    end;

    local procedure PrepareTempDataSet(var TempTrackingSpecification: Record "Tracking Specification" temporary; QtyToPrepare: Decimal): Boolean
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ReservEntry2: Record "Reservation Entry";
    begin
        if QtyToPrepare <= 0 then
            exit(true);

        TempTrackingSpecification.Reset;

        ItemLedgEntry.SetCurrentKey("Item No.", Open, "Variant Code", Positive, "Location Code");
        ItemLedgEntry.SetRange("Item No.", TempTrackingSpecification."Item No.");
        ItemLedgEntry.SetRange("Variant Code", TempTrackingSpecification."Variant Code");
        ItemLedgEntry.SetRange("Location Code", TempTrackingSpecification."Location Code");
        ItemLedgEntry.SetRange(Positive, true);
        ItemLedgEntry.SetRange(Open, true);

        ReservEntry2.SetSourceFilter(DATABASE::"Item Ledger Entry", 0, '', -1, true);
        ReservEntry2.SetRange("Untracked Surplus", false);
        if ItemLedgEntry.FindSet then
            repeat
                TempTrackingSpecification.SetTrackingFilter(ItemLedgEntry."Serial No.", ItemLedgEntry."Lot No.", ItemLedgEntry."CD No.");
                if TempTrackingSpecification.IsEmpty then begin
                    InsertTempSupplyReservEntry(ItemLedgEntry);
                    // GET record
                    QtyToPrepare -= ItemLedgEntry."Remaining Quantity";
                    TempSupplyReservEntry.Get(-ItemLedgEntry."Entry No.", true);
                    ReservEntry2.SetRange("Source Ref. No.", ItemLedgEntry."Entry No.");
                    if ReservEntry2.FindSet then
                        repeat
                            TempSupplyReservEntry."Quantity (Base)" -= ReservEntry2."Quantity (Base)";
                            TempSupplyReservEntry.Modify;

                            if ReservEntry2."Reservation Status" = ReservEntry2."Reservation Status"::Surplus then begin
                                TempSupplyReservEntry := ReservEntry2;
                                TempSupplyReservEntry.Insert;
                            end else
                                QtyToPrepare += ReservEntry2."Quantity (Base)";
                        until ReservEntry2.Next = 0;
                    if TempSupplyReservEntry."Quantity (Base)" = 0 then
                        TempSupplyReservEntry.Delete
                end;
            until (ItemLedgEntry.Next = 0) or (QtyToPrepare <= 0);

        TempTrackingSpecification.Reset;
        exit(QtyToPrepare <= 0);
    end;

    local procedure ReshuffleReservEntry(SupplyReservEntry: Record "Reservation Entry"; QtyToReshuffle: Decimal; var TempTrackingSpecification: Record "Tracking Specification" temporary) RemainingQty: Decimal
    var
        TotalAvailable: Decimal;
        QtyToReshuffleThisLine: Decimal;
        xQtyToReshuffleThisLine: Decimal;
        AdjustmentQty: Decimal;
        NewQty: Decimal;
        xQty: Decimal;
    begin
        if SupplyReservEntry."Reservation Status" > SupplyReservEntry."Reservation Status"::Tracking then
            exit; // The entry is neither reservation nor tracking and cannot be reshuffled

        if not SupplyReservEntry.Positive then
            exit; // The entry is not supply and cannot be reshuffled

        TempCurrDemandReservEntry.Get(SupplyReservEntry."Entry No.", not SupplyReservEntry.Positive); // Demand

        if TempCurrDemandReservEntry.TrackingExists then // The reservation is not open
            exit; // The entry is a specific allocation and cannot be reshuffled

        if QtyToReshuffle <= 0 then
            exit;

        TempSupplyReservEntry.CalcSums("Quantity (Base)");
        TotalAvailable := TempSupplyReservEntry."Quantity (Base)";

        if TotalAvailable < QtyToReshuffle then
            Error(Text001);

        if SupplyReservEntry."Quantity (Base)" > QtyToReshuffle then
            QtyToReshuffleThisLine := QtyToReshuffle
        else
            QtyToReshuffleThisLine := SupplyReservEntry."Quantity (Base)";

        xQtyToReshuffleThisLine := QtyToReshuffleThisLine;

        TempSupplyReservEntry.SetRange("Reservation Status", TempSupplyReservEntry."Reservation Status"::Surplus);
        if TempSupplyReservEntry.FindSet then
            repeat
                TempTrackingSpecification.SetTrackingFilter(
                  TempSupplyReservEntry."Serial No.", TempSupplyReservEntry."Lot No.", TempSupplyReservEntry."CD No.");
                if TempTrackingSpecification.FindFirst then begin
                    if TempTrackingSpecification."Buffer Value4" > 0 then begin
                        if TempTrackingSpecification."Buffer Value4" < QtyToReshuffleThisLine then begin
                            AdjustmentQty := QtyToReshuffleThisLine - TempTrackingSpecification."Buffer Value4";
                            QtyToReshuffleThisLine := TempTrackingSpecification."Buffer Value4";
                        end else
                            AdjustmentQty := 0;

                        xQty := QtyToReshuffleThisLine;
                        QtyToReshuffleThisLine := MakeConnection(TempSupplyReservEntry, TempCurrDemandReservEntry, QtyToReshuffleThisLine);
                        TempTrackingSpecification."Buffer Value4" -= (xQty - QtyToReshuffleThisLine);
                        TempTrackingSpecification.Modify;
                        QtyToReshuffleThisLine += AdjustmentQty;
                    end;
                end else
                    QtyToReshuffleThisLine := MakeConnection(TempSupplyReservEntry, TempCurrDemandReservEntry, QtyToReshuffleThisLine);

            until (TempSupplyReservEntry.Next = 0) or (QtyToReshuffleThisLine = 0);

        RemainingQty := QtyToReshuffle - xQtyToReshuffleThisLine + QtyToReshuffleThisLine;

        // Modify the original demand/supply entries

        NewQty := SupplyReservEntry."Quantity (Base)" - xQtyToReshuffleThisLine + QtyToReshuffleThisLine;
        if NewQty = 0 then begin
            TempReservEntryDelete := SupplyReservEntry;
            TempReservEntryDelete.Insert;
            TempReservEntryDelete := TempCurrDemandReservEntry;
            TempReservEntryDelete.Insert;
        end else begin
            TempReservEntryModify := SupplyReservEntry;
            TempReservEntryModify."Quantity (Base)" := NewQty;
            TempReservEntryModify.Insert;
            TempReservEntryModify := TempCurrDemandReservEntry;
            TempReservEntryModify."Quantity (Base)" := -NewQty;
            TempReservEntryModify.Insert;
        end;

        TempTrackingSpecification.Reset;
    end;

    local procedure MakeConnection(var SupplySurplusEntry: Record "Reservation Entry"; var DemandReservEntry: Record "Reservation Entry"; QtyToReshuffle: Decimal) RemainingQty: Decimal
    var
        NewEntryNo: Integer;
    begin
        if SupplySurplusEntry."Quantity (Base)" = 0 then
            exit(QtyToReshuffle);

        if SupplySurplusEntry."Quantity (Base)" <= QtyToReshuffle then begin
            // Convert supply surplus fully
            if SupplySurplusEntry."Entry No." < 0 then begin // Item Ledger Entry temporary record
                LastEntryNo := LastEntryNo + 1;
                NewEntryNo := -LastEntryNo;
            end else
                NewEntryNo := SupplySurplusEntry."Entry No.";

            TempReservEntryInsert := DemandReservEntry;
            TempReservEntryInsert."Entry No." := NewEntryNo;
            TempReservEntryInsert."Expected Receipt Date" := SupplySurplusEntry."Expected Receipt Date";
            TempReservEntryInsert."Quantity (Base)" := -SupplySurplusEntry."Quantity (Base)";
            TempReservEntryInsert.Insert;

            TempReservEntryModify := SupplySurplusEntry;
            TempReservEntryModify."Entry No." := NewEntryNo;
            TempReservEntryModify."Reservation Status" := DemandReservEntry."Reservation Status";
            TempReservEntryModify."Shipment Date" := DemandReservEntry."Shipment Date";

            if SupplySurplusEntry."Entry No." < 0 then begin // Entry does not really exist
                TempReservEntryInsert := TempReservEntryModify;
                TempReservEntryInsert.Insert;
            end else
                TempReservEntryModify.Insert;

            RemainingQty := QtyToReshuffle - SupplySurplusEntry."Quantity (Base)";
            SupplySurplusEntry."Quantity (Base)" := 0;
            SupplySurplusEntry.Modify;
        end else begin
            if SupplySurplusEntry."Entry No." > 0 then begin
                TempReservEntryModify := SupplySurplusEntry;
                TempReservEntryModify."Quantity (Base)" -= QtyToReshuffle;
                TempReservEntryModify.Insert;
            end;

            LastEntryNo := LastEntryNo + 1;
            NewEntryNo := -LastEntryNo;
            TempReservEntryInsert := SupplySurplusEntry;
            TempReservEntryInsert."Entry No." := NewEntryNo;
            TempReservEntryInsert."Reservation Status" := DemandReservEntry."Reservation Status";
            TempReservEntryInsert.Validate("Quantity (Base)", QtyToReshuffle);
            TempReservEntryInsert."Shipment Date" := DemandReservEntry."Shipment Date";
            TempReservEntryInsert.Insert;

            TempReservEntryInsert := DemandReservEntry;
            TempReservEntryInsert."Entry No." := NewEntryNo;
            TempReservEntryInsert."Expected Receipt Date" := SupplySurplusEntry."Expected Receipt Date";
            TempReservEntryInsert.Validate("Quantity (Base)", -QtyToReshuffle);
            TempReservEntryInsert.Insert;

            SupplySurplusEntry."Quantity (Base)" -= QtyToReshuffle;
            SupplySurplusEntry.Modify;
            RemainingQty := 0;
        end;
    end;

    local procedure WriteToDatabase()
    var
        ReservEntry: Record "Reservation Entry";
        PrevNegEntryNo: Integer;
        LastInsertedEntryNo: Integer;
    begin
        TempReservEntryDelete.Reset;
        TempReservEntryModify.Reset;
        TempReservEntryInsert.Reset;

        if TempReservEntryDelete.FindSet then
            repeat
                ReservEntry := TempReservEntryDelete;
                ReservEntry.Delete;
            until TempReservEntryDelete.Next = 0;

        if TempReservEntryModify.FindSet then
            repeat
                ReservEntry := TempReservEntryModify;
                ReservEntry.Validate("Quantity (Base)");
                ReservEntry.Modify;
            until TempReservEntryModify.Next = 0;

        if TempReservEntryInsert.FindSet then
            repeat
                ReservEntry := TempReservEntryInsert;
                if ReservEntry."Entry No." < 0 then
                    if ReservEntry."Entry No." = PrevNegEntryNo then
                        ReservEntry."Entry No." := LastInsertedEntryNo
                    else begin
                        PrevNegEntryNo := ReservEntry."Entry No.";
                        ReservEntry."Entry No." := 0;
                    end;
                ReservEntry.Validate("Quantity (Base)");
                ReservEntry.UpdateItemTracking;
                ReservEntry.Insert;
                LastInsertedEntryNo := ReservEntry."Entry No.";
            until TempReservEntryInsert.Next = 0;
    end;

    local procedure CalcInventory(var TempTrackingSpecification: Record "Tracking Specification" temporary): Boolean
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ReservEntry: Record "Reservation Entry";
        TotalReservedQty: Decimal;
    begin
        ReservEntry.LockTable;
        ReservEntry.SetCurrentKey("Item No.", "Source Type", "Source Subtype", "Reservation Status", "Location Code", "Variant Code");
        ReservEntry.SetRange("Item No.", TempTrackingSpecification."Item No.");
        ReservEntry.SetRange("Variant Code", TempTrackingSpecification."Variant Code");
        ReservEntry.SetRange("Location Code", TempTrackingSpecification."Location Code");
        ReservEntry.SetRange("Source Type", DATABASE::"Item Ledger Entry");
        ReservEntry.SetRange("Source Subtype", 0);
        ReservEntry.SetRange("Reservation Status", ReservEntry."Reservation Status"::Reservation);
        ReservEntry.SetFilter("Item Tracking", '<> %1', ReservEntry."Item Tracking"::None);

        if ReservEntry.IsEmpty then  // No reservations with Item Tracking exist against inventory - no basis for reallocation.
            exit(false);

        ItemLedgEntry.SetCurrentKey("Item No.", Open, "Variant Code", Positive, "Location Code");
        ItemLedgEntry.SetRange("Item No.", TempTrackingSpecification."Item No.");
        ItemLedgEntry.SetRange("Variant Code", TempTrackingSpecification."Variant Code");
        ItemLedgEntry.SetRange("Location Code", TempTrackingSpecification."Location Code");
        ItemLedgEntry.SetRange(Positive, true);
        ItemLedgEntry.SetRange(Open, true);

        if TempTrackingSpecification.FindSet then
            repeat
                ItemLedgEntry.SetRange("Serial No.", TempTrackingSpecification."Serial No.");
                ItemLedgEntry.SetRange("Lot No.", TempTrackingSpecification."Lot No.");
                ItemLedgEntry.SetRange("CD No.", TempTrackingSpecification."CD No.");

                if ItemLedgEntry.FindSet then
                    repeat
                        TempTrackingSpecification."Buffer Value2" += ItemLedgEntry."Remaining Quantity";
                        ItemLedgEntry.CalcFields("Reserved Quantity");
                        TempTrackingSpecification."Buffer Value3" += ItemLedgEntry."Reserved Quantity";
                        InsertTempSupplyReservEntry(ItemLedgEntry);
                    until ItemLedgEntry.Next = 0;

                TempTrackingSpecification."Buffer Value4" :=
                  TempTrackingSpecification."Buffer Value2" - // Total Inventory
                  TempTrackingSpecification."Buffer Value3" + // Reserved Inventory
                  TempTrackingSpecification."Buffer Value1";  // Non-allocated lot/sn demand (signed negatively)
                TempTrackingSpecification.Modify;
                TotalReservedQty += TempTrackingSpecification."Buffer Value3";
            until TempTrackingSpecification.Next = 0;

        if TotalReservedQty = 0 then
            exit(false); // No need to consider reallocation if no reservations exist.

        exit(true);
    end;

    local procedure CalcAllocations(var TempTrackingSpecification: Record "Tracking Specification" temporary): Boolean
    var
        ReservEntry: Record "Reservation Entry";
        ReservEntry2: Record "Reservation Entry";
        QtyNeededForReallocation: Decimal;
    begin
        ReservEntry.SetCurrentKey("Item No.", "Source Type", "Source Subtype", "Reservation Status", "Location Code", "Variant Code");
        ReservEntry.SetRange("Item No.", TempTrackingSpecification."Item No.");
        ReservEntry.SetRange("Variant Code", TempTrackingSpecification."Variant Code");
        ReservEntry.SetRange("Location Code", TempTrackingSpecification."Location Code");
        ReservEntry.SetRange("Source Type", DATABASE::"Item Ledger Entry"); // (ILE)
        ReservEntry.SetRange("Source Subtype", 0);
        ReservEntry.SetRange(Positive, true);
        ReservEntry.SetRange("Reservation Status",
          ReservEntry."Reservation Status"::Reservation, ReservEntry."Reservation Status"::Tracking);

        TempTrackingSpecification.SetFilter("Buffer Value4", '< %1', 0);

        if TempTrackingSpecification.FindSet then
            repeat
                if TempTrackingSpecification."Serial No." <> '' then
                    ReservEntry.SetRange("Serial No.", TempTrackingSpecification."Serial No.")
                else
                    ReservEntry.SetRange("Serial No.");
                if TempTrackingSpecification."Lot No." <> '' then
                    ReservEntry.SetRange("Lot No.", TempTrackingSpecification."Lot No.")
                else
                    ReservEntry.SetRange("Lot No.");
                if TempTrackingSpecification."CD No." <> '' then
                    ReservEntry.SetRange("CD No.", TempTrackingSpecification."CD No.")
                else
                    ReservEntry.SetRange("CD No.");
                if ReservEntry.FindSet(true, true) then
                    repeat
                        ReservEntry2.Get(ReservEntry."Entry No.", not ReservEntry.Positive); // Get demand
                        if not ReservEntry2.TrackingExists then begin
                            TempCurrSupplyReservEntry := ReservEntry;
                            TempCurrSupplyReservEntry.Insert;
                            TempTrackingSpecification."Buffer Value5" += ReservEntry."Quantity (Base)";
                            TempCurrDemandReservEntry := ReservEntry2;
                            TempCurrDemandReservEntry.Insert;
                        end;
                    until (ReservEntry.Next = 0) or
                          (TempTrackingSpecification."Buffer Value4" + TempTrackingSpecification."Buffer Value5" >= 0);
                if TempTrackingSpecification."Buffer Value4" + TempTrackingSpecification."Buffer Value5" < 0 then // Not sufficient qty
                    exit(false);
                TempTrackingSpecification.Modify;
                QtyNeededForReallocation += Abs(TempTrackingSpecification."Buffer Value4");
            until TempTrackingSpecification.Next = 0;

        TempTrackingSpecification.SetFilter("Buffer Value4", '>= %1', 0);
        ReservEntry.SetRange("Reservation Status");

        // The quantity temporary records representing Item Ledger Entries are adjusted according to the
        // reservation entries actually existing in the database pointing at those entries. Otherwise these
        // would be counted twice.
        if TempTrackingSpecification.FindSet then
            repeat
                if TempTrackingSpecification."Serial No." <> '' then
                    ReservEntry.SetRange("Serial No.", TempTrackingSpecification."Serial No.")
                else
                    ReservEntry.SetRange("Serial No.");
                if TempTrackingSpecification."Lot No." <> '' then
                    ReservEntry.SetRange("Lot No.", TempTrackingSpecification."Lot No.")
                else
                    ReservEntry.SetRange("Lot No.");
                if TempTrackingSpecification."CD No." <> '' then
                    ReservEntry.SetRange("CD No.", TempTrackingSpecification."CD No.")
                else
                    ReservEntry.SetRange("CD No.");

                if ReservEntry.FindSet then
                    repeat
                        TempSupplyReservEntry.Get(-ReservEntry."Source Ref. No.", true);
                        TempSupplyReservEntry."Quantity (Base)" -= ReservEntry."Quantity (Base)";
                        if TempSupplyReservEntry."Quantity (Base)" = 0 then
                            TempSupplyReservEntry.Delete
                        else
                            TempSupplyReservEntry.Modify;

                        if ReservEntry."Reservation Status" = ReservEntry."Reservation Status"::Surplus then begin
                            TempSupplyReservEntry := ReservEntry;
                            TempSupplyReservEntry.Insert;
                        end;
                    until (ReservEntry.Next = 0);
                QtyNeededForReallocation -= TempTrackingSpecification."Buffer Value4";
            until (TempTrackingSpecification.Next = 0);
        exit(QtyNeededForReallocation <= 0);
    end;

    local procedure InsertTempSupplyReservEntry(ItemLedgEntry: Record "Item Ledger Entry")
    begin
        TempSupplyReservEntry.Init;
        TempSupplyReservEntry."Entry No." := -ItemLedgEntry."Entry No.";
        TempSupplyReservEntry.Positive := true;

        TempSupplyReservEntry."Source Type" := DATABASE::"Item Ledger Entry";
        TempSupplyReservEntry."Source Ref. No." := ItemLedgEntry."Entry No.";

        TempSupplyReservEntry."Item No." := ItemLedgEntry."Item No.";
        TempSupplyReservEntry."Variant Code" := ItemLedgEntry."Variant Code";
        TempSupplyReservEntry."Location Code" := ItemLedgEntry."Location Code";
        TempSupplyReservEntry."Qty. per Unit of Measure" := ItemLedgEntry."Qty. per Unit of Measure";
        TempSupplyReservEntry.Description := ItemLedgEntry.Description;
        TempSupplyReservEntry."Serial No." := ItemLedgEntry."Serial No.";
        TempSupplyReservEntry."Lot No." := ItemLedgEntry."Lot No.";
        TempSupplyReservEntry."CD No." := ItemLedgEntry."CD No.";
        TempSupplyReservEntry."Quantity (Base)" := ItemLedgEntry."Remaining Quantity";
        TempSupplyReservEntry."Reservation Status" := TempSupplyReservEntry."Reservation Status"::Surplus;
        TempSupplyReservEntry."Expected Receipt Date" := 0D;
        TempSupplyReservEntry."Shipment Date" := 0D;
        OnBeforeTempSupplyReservEntryInsert(TempSupplyReservEntry, ItemLedgEntry);
        TempSupplyReservEntry.Insert;
    end;

    procedure NonspecificReservedQty(var ItemLedgEntry: Record "Item Ledger Entry") UnspecificQty: Decimal
    var
        ReservEntry: Record "Reservation Entry";
        ReservEntry2: Record "Reservation Entry";
    begin
        if not ItemLedgEntry.FindSet then
            exit;

        ReservEntry.SetCurrentKey("Item No.", "Source Type", "Source Subtype", "Reservation Status", "Location Code", "Variant Code");
        ReservEntry.SetRange("Item No.", ItemLedgEntry."Item No.");
        ReservEntry.SetRange("Variant Code", ItemLedgEntry."Variant Code");
        ReservEntry.SetRange("Location Code", ItemLedgEntry."Location Code");
        ReservEntry.SetRange("Source Type", DATABASE::"Item Ledger Entry");
        ReservEntry.SetRange("Source Subtype", 0);
        ReservEntry.SetRange("Reservation Status", ReservEntry."Reservation Status"::Reservation);
        ReservEntry.SetRange(Positive, true);
        ItemLedgEntry.CopyFilter("Serial No.", ReservEntry."Serial No.");
        ItemLedgEntry.CopyFilter("Lot No.", ReservEntry."Lot No.");
        ItemLedgEntry.CopyFilter("CD No.", ReservEntry."CD No.");

        if not ReservEntry.FindSet then
            exit;

        repeat
            ReservEntry2.Get(ReservEntry."Entry No.", not ReservEntry.Positive);  // Get demand
            if not ReservEntry2.TrackingExists then
                UnspecificQty -= ReservEntry2."Quantity (Base)"; // Sum up negative entries to a positive value
        until ReservEntry.Next = 0;
    end;

    procedure ReleaseForReservation(ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; SerialNo: Code[50]; LotNo: Code[50]; CDNo: Code[30]; QtyToRelease: Decimal) AllocationsChanged: Boolean
    var
        TempTrackingSpecification: Record "Tracking Specification" temporary;
    begin
        // Local procedure used when doing item tracking specific reservations
        // "Buffer Value4" : Qty for reallocation (negative = need for reallocation)

        CleanUpVariables;
        TempTrackingSpecification."Item No." := ItemNo;
        TempTrackingSpecification."Variant Code" := VariantCode;
        TempTrackingSpecification."Location Code" := LocationCode;
        TempTrackingSpecification."Serial No." := SerialNo;
        TempTrackingSpecification."Lot No." := LotNo;
        TempTrackingSpecification."CD No." := CDNo;
        TempTrackingSpecification."Quantity (Base)" := QtyToRelease;
        TempTrackingSpecification."Buffer Value4" := -QtyToRelease;
        TempTrackingSpecification.Insert;

        PrepareTempDataSet(TempTrackingSpecification, QtyToRelease);
        CalcAllocations(TempTrackingSpecification);
        AllocationsChanged := Reallocate(TempTrackingSpecification);
        WriteToDatabase;
    end;

    procedure ReleaseForReservation(var CalcItemLedgEntry: Record "Item Ledger Entry"; CalcReservEntry: Record "Reservation Entry"; RemainingQtyToReserve: Decimal) AllocationsChanged: Boolean
    var
        AvailableToReserve: Decimal;
    begin
        // Used when doing item tracking specific reservations on reservation form.
        // "Buffer Value4" : Qty for reallocation (negative = need for reallocation)

        if CalcItemLedgEntry.FindSet then
            repeat
                CalcItemLedgEntry.CalcFields("Reserved Quantity");
                AvailableToReserve +=
                  CalcItemLedgEntry."Remaining Quantity" - CalcItemLedgEntry."Reserved Quantity";
            until (CalcItemLedgEntry.Next = 0) or (AvailableToReserve >= RemainingQtyToReserve);

        if AvailableToReserve < RemainingQtyToReserve then
            AllocationsChanged := ReleaseForReservation(
                CalcReservEntry."Item No.", CalcReservEntry."Variant Code", CalcReservEntry."Location Code",
                CalcReservEntry."Serial No.", CalcReservEntry."Lot No.", CalcReservEntry."CD No.", RemainingQtyToReserve - AvailableToReserve);
    end;

    procedure ReserveItemTrackingLine(TrackingSpecification: Record "Tracking Specification")
    var
        ReservEntry: Record "Reservation Entry";
        QtyToReserveBase: Decimal;
        QtyToReserve: Decimal;
        UnreservedQty: Decimal;
        AvailabilityDate: Date;
    begin
        // Used when fully reserving an item tracking line
        QtyToReserveBase := TrackingSpecification."Quantity (Base)" - TrackingSpecification."Quantity Handled (Base)";

        if QtyToReserveBase <= 0 then
            exit;

        ReservMgt.SetCalcReservEntry(TrackingSpecification, ReservEntry);

        if ReservEntry."Quantity (Base)" < 0 then
            AvailabilityDate := ReservEntry."Shipment Date"
        else
            AvailabilityDate := ReservEntry."Expected Receipt Date";

        UnreservedQty :=
          TrackingSpecification."Quantity (Base)" - TrackingSpecification."Quantity Handled (Base)";

        ReservEntry.SetCurrentKey(
          "Source ID", "Source Ref. No.", "Source Type", "Source Subtype",
          "Source Batch Name", "Source Prod. Order Line", "Reservation Status");
        ReservEntry.SetPointerFilter;
        ReservEntry.SetTrackingFilter(ReservEntry."Serial No.", ReservEntry."Lot No.", ReservEntry."CD No.");
        ReservEntry.SetRange("Reservation Status", ReservEntry."Reservation Status"::Reservation);
        if ReservEntry.FindSet then
            repeat
                UnreservedQty -= Abs(ReservEntry."Quantity (Base)");
            until ReservEntry.Next = 0;

        if QtyToReserveBase > UnreservedQty then
            QtyToReserveBase := UnreservedQty;

        ReservMgt.AutoReserveOneLine(1, QtyToReserve, QtyToReserveBase, '', AvailabilityDate);
    end;

    procedure ReserveItemTrackingLine(TrackingSpecification: Record "Tracking Specification"; QtyToReserve: Decimal; QtyToReserveBase: Decimal)
    var
        ReservEntry: Record "Reservation Entry";
        AvailabilityDate: Date;
    begin
        // Used when reserving a specific quantity on an item tracking line
        if QtyToReserveBase <= 0 then
            exit;

        ReservMgt.SetCalcReservEntry(TrackingSpecification, ReservEntry);

        if ReservEntry."Quantity (Base)" < 0 then
            AvailabilityDate := ReservEntry."Shipment Date"
        else
            AvailabilityDate := ReservEntry."Expected Receipt Date";

        ReservMgt.AutoReserveOneLine(1, QtyToReserve, QtyToReserveBase, '', AvailabilityDate);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTempSupplyReservEntryInsert(var ReservationEntry: Record "Reservation Entry"; ItemLedgerEntry: Record "Item Ledger Entry")
    begin
    end;
}

