codeunit 10332 "Exp. Mapping Head EFT CA"
{
    TableNo = "Data Exch.";

    trigger OnRun()
    var
        ACHRBHeader: Record "ACH RB Header";
        DataExch: Record "Data Exch.";
        DataExchLineDef: Record "Data Exch. Line Def";
        EFTExportMgt: Codeunit "EFT Export Mgt";
        RecordRef: RecordRef;
        LineNo: Integer;
    begin
        // Range through the Header record
        LineNo := 1;
        DataExchLineDef.Init;
        DataExchLineDef.SetRange("Data Exch. Def Code", "Data Exch. Def Code");
        DataExchLineDef.SetRange("Line Type", DataExchLineDef."Line Type"::Header);
        if DataExchLineDef.FindFirst then begin
            DataExch.SetRange("Entry No.", "Entry No.");
            if DataExch.FindFirst then
                if ACHRBHeader.Get("Entry No.") then begin
                    RecordRef.GetTable(ACHRBHeader);
                    EFTExportMgt.InsertDataExchLineForFlatFile(
                      DataExch,
                      LineNo,
                      RecordRef);
                end;
        end;
    end;
}

