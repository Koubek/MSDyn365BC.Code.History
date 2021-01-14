page 17283 "Tax Reg. Norm Term Formula"
{
    AutoSplitKey = true;
    Caption = 'Norm Term Lines';
    PageType = List;
    SourceTable = "Tax Reg. Norm Term Formula";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Operation; Operation)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = OperationEditable;
                    ToolTip = 'Specifies the operation associated with the norm term line.';
                }
                field("Account Type"; "Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = AccountTypeEditable;
                    ToolTip = 'Specifies the purpose of the account.';

                    trigger OnValidate()
                    begin
                        AccountTypeOnAfterValidate;
                    end;
                }
                field("Account No."; "Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the account number associated with the norm term line.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        case "Account Type" of
                            "Account Type"::"GL Acc", "Account Type"::"Net Change":
                                begin
                                    GLAcc.Reset;
                                    if "Bal. Account No." <> '' then
                                        if StrPos('|&<>', CopyStr("Account No.", StrLen("Account No."))) = 0 then begin
                                            GLAcc.SetFilter("No.", "Account No.");
                                            if GLAcc.FindFirst then;
                                            GLAcc.SetRange("No.");
                                        end;
                                    if ACTION::LookupOK = PAGE.RunModal(0, GLAcc) then begin
                                        Text := GLAcc."No.";
                                        exit(true);
                                    end;
                                end;
                            "Account Type"::Termin:
                                begin
                                    NormTermName.Reset;
                                    if "Account No." <> '' then begin
                                        NormTermName.SetFilter("Term Code", "Account No.");
                                        if NormTermName.FindFirst then;
                                        NormTermName.SetRange("Term Code");
                                    end;
                                    if ACTION::LookupOK = PAGE.RunModal(0, NormTermName) then begin
                                        "Account No." := '';
                                        Text := NormTermName."Term Code";
                                        exit(true);
                                    end;
                                end;
                            "Account Type"::Norm:
                                if "Jurisdiction Code" <> '' then begin
                                    NormGroup.Reset;
                                    NormGroup.FilterGroup(2);
                                    NormGroup.SetRange("Norm Jurisdiction Code", "Jurisdiction Code");
                                    NormGroup.FilterGroup(0);
                                    NormGroup.SetRange("Has Details", true);
                                    if NormGroup.Get("Jurisdiction Code", CopyStr("Account No.", 1, MaxStrLen(NormGroup.Code))) then;
                                    if ACTION::LookupOK = PAGE.RunModal(0, NormGroup) then begin
                                        "Account No." := '';
                                        Text := NormGroup.Code;
                                        exit(true);
                                    end;
                                end;
                        end;
                        exit(false);
                    end;

                    trigger OnValidate()
                    begin
                        AccountNoOnAfterValidate;
                    end;
                }
                field("Bal. Account No."; "Bal. Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = BalAccountNoEditable;
                    ToolTip = 'Specifies the number of the general ledger, customer, vendor, or bank account to which a balancing entry will posted, such as a cash account for cash purchases.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if "Account Type" = "Account Type"::"Net Change" then begin
                            GLAcc.Reset;
                            if "Bal. Account No." <> '' then
                                if StrPos('|&<>', CopyStr("Bal. Account No.", StrLen("Bal. Account No."))) = 0 then begin
                                    GLAcc.SetFilter("No.", "Bal. Account No.");
                                    if GLAcc.FindFirst then;
                                    GLAcc.SetRange("No.");
                                end;
                            if ACTION::LookupOK = PAGE.RunModal(0, GLAcc) then begin
                                Text := GLAcc."No.";
                                exit(true);
                            end;
                        end;
                        CalcFields("Expression Type");
                        if "Expression Type" = "Expression Type"::Compare then begin
                            NormTermName.Reset;
                            if "Bal. Account No." <> '' then begin
                                NormTermName.SetFilter("Term Code", "Bal. Account No.");
                                if NormTermName.FindFirst then;
                                NormTermName.SetRange("Term Code");
                            end;
                            if ACTION::LookupOK = PAGE.RunModal(0, NormTermName) then begin
                                "Bal. Account No." := '';
                                Text := NormTermName."Term Code";
                                exit(true);
                            end;
                        end;
                        exit(false);
                    end;
                }
                field("Amount Type"; "Amount Type")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = AmountTypeEditable;
                    ToolTip = 'Specifies the amount type associated with the norm term line.';
                }
                field("Process Sign"; "Process Sign")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the process sign. Norm jurisdictions are based on Russian tax laws that define a variety of tax rates. They are used to calculate taxable profits and losses in tax accounting. Process signs include Skip Negative, Skip Positive, Always Positive, Always Negative.';
                }
                field("Process Division by Zero"; "Process Division by Zero")
                {
                    ToolTip = 'Specifies the process division by zero associated with the norm term line.';
                    Visible = false;
                }
                field("Jurisdiction Code"; "Jurisdiction Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the jurisdiction code associated with the norm term line.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetEnable;
    end;

    trigger OnAfterGetRecord()
    begin
        SetEnable;
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        CalcFields("Expression Type");
        if "Expression Type" = "Expression Type"::Compare then begin
            if not Confirm(Text001, false) then
                exit(false);
            DeleteAll;
            CurrPage.Close;
        end;
        exit(true);
    end;

    trigger OnInit()
    begin
        AmountTypeEditable := true;
        AccountTypeEditable := true;
        OperationEditable := true;
        BalAccountNoEditable := true;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        CalcFields("Expression Type");
        if "Expression Type" = "Expression Type"::"Plus/Minus" then
            Operation := Operation::"+"
        else
            if "Expression Type" = "Expression Type"::"Multiply/Divide" then
                Operation := Operation::"*"
            else begin
                if not (Count = 3) then
                    CurrPage.Close;
                Operation := Operation::Negative;
                "Account Type" := "Account Type"::Termin;
            end;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        CalcFields("Expression Type");
        if not ("Expression Type" = "Expression Type"::Compare) then
            exit(true);
        if not (Count = 3) then
            exit(true);
        ExternReportFormula1.Copy(Rec);
        ExternReportFormula1.FindSet;
        if ExternReportFormula1."Account No." = '' then begin
            Rec := ExternReportFormula1;
            CurrPage.Update(false);
            ExternReportFormula1.TestField("Account No.");
        end;
        repeat
            if ExternReportFormula1."Bal. Account No." = '' then begin
                Rec := ExternReportFormula1;
                CurrPage.Update(false);
                ExternReportFormula1.TestField("Bal. Account No.");
            end;
        until ExternReportFormula1.Next = 0;
    end;

    var
        Text001: Label 'Delete all lines?';
        GLAcc: Record "G/L Account";
        ExternReportFormula1: Record "Tax Reg. Norm Term Formula";
        NormTermName: Record "Tax Reg. Norm Term";
        NormGroup: Record "Tax Register Norm Group";
        [InDataSet]
        BalAccountNoEditable: Boolean;
        [InDataSet]
        OperationEditable: Boolean;
        [InDataSet]
        AccountTypeEditable: Boolean;
        [InDataSet]
        AmountTypeEditable: Boolean;

    local procedure SetEnable()
    begin
        CalcFields("Expression Type");
        if "Expression Type" = "Expression Type"::Compare then begin
            BalAccountNoEditable := true;
            OperationEditable := false;
            AccountTypeEditable := false;
        end else
            BalAccountNoEditable := "Account Type" = "Account Type"::"Net Change";

        AmountTypeEditable := "Account Type" in ["Account Type"::"GL Acc", "Account Type"::"Net Change"];
    end;

    local procedure AccountTypeOnAfterValidate()
    begin
        SetEnable;
    end;

    local procedure AccountNoOnAfterValidate()
    begin
        SetEnable;
        CurrPage.Update(true);
    end;
}

