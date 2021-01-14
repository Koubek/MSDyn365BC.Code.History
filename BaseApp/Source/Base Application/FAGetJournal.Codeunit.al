codeunit 5639 "FA Get Journal"
{

    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'You cannot duplicate using the current journal. Check the table %1.';
        DeprBook: Record "Depreciation Book";
        FAJnlSetup: Record "FA Journal Setup";
        FAJnlTemplate: Record "FA Journal Template";
        FAJnlBatch: Record "FA Journal Batch";
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Batch";
        InsuranceJnlTempl: Record "Insurance Journal Template";
        InsuranceJnlBatch: Record "Insurance Journal Batch";
        TemplateName2: Code[10];
        BatchName2: Code[10];
        Text001: Label 'You cannot copy in current journal Control table %1.';
        Text12400: Label 'FA Journal Setup with Depreciation Book Code %1 User ID %2 does not exist';

    procedure JnlName(DeprBookCode: Code[10]; BudgetAsset: Boolean; FAPostingType: Enum "FA Journal Line FA Posting Type"; var GLIntegration: Boolean; var TemplateName: Code[10]; var BatchName: Code[10])
    var
        GLIntegration2: Boolean;
    begin
        DeprBook.Get(DeprBookCode);
        if not FAJnlSetup.Get(DeprBookCode, UserId) then
            if not FAJnlSetup.Get(DeprBookCode, '') then
                Error(Text12400, DeprBookCode, UserId);
        GLIntegration2 := GLIntegration;
        GLIntegration := CalcGLIntegration(BudgetAsset, FAPostingType);
        BatchName2 := BatchName;
        TemplateName2 := TemplateName;
        if GLIntegration then begin
            FAJnlSetup.TestField("Gen. Jnl. Template Name");
            FAJnlSetup.TestField("Gen. Jnl. Batch Name");
            TemplateName := FAJnlSetup."Gen. Jnl. Template Name";
            BatchName := FAJnlSetup."Gen. Jnl. Batch Name";
            GenJnlTemplate.Get(TemplateName);
            GenJnlBatch.Get(TemplateName, BatchName);
        end else begin
            FAJnlSetup.TestField("FA Jnl. Batch Name");
            FAJnlSetup.TestField("FA Jnl. Template Name");
            TemplateName := FAJnlSetup."FA Jnl. Template Name";
            BatchName := FAJnlSetup."FA Jnl. Batch Name";
            FAJnlTemplate.Get(TemplateName);
            FAJnlBatch.Get(TemplateName, BatchName);
        end;
        if (GLIntegration = GLIntegration2) and
           (BatchName = BatchName2) and
           (TemplateName = TemplateName2)
        then
            Error(Text000, FAJnlSetup.TableCaption);
    end;

    procedure InsuranceJnlName(DeprBookCode: Code[10]; var TemplateName: Code[10]; var BatchName: Code[10])
    begin
        DeprBook.Get(DeprBookCode);
        if not FAJnlSetup.Get(DeprBookCode, UserId) then
            FAJnlSetup.Get(DeprBookCode, '');
        FAJnlSetup.TestField("Insurance Jnl. Template Name");
        FAJnlSetup.TestField("Insurance Jnl. Batch Name");
        BatchName := FAJnlSetup."Insurance Jnl. Batch Name";
        TemplateName := FAJnlSetup."Insurance Jnl. Template Name";
        InsuranceJnlTempl.Get(TemplateName);
        InsuranceJnlBatch.Get(TemplateName, BatchName);
    end;

    procedure SetGenJnlRange(var GenJnlLine: Record "Gen. Journal Line"; TemplateName: Code[10]; BatchName: Code[10])
    begin
        with GenJnlLine do begin
            Reset;
            "Journal Template Name" := TemplateName;
            "Journal Batch Name" := BatchName;
            SetRange("Journal Template Name", TemplateName);
            SetRange("Journal Batch Name", BatchName);
            if Find('+') then;
            Init;
        end;
    end;

    procedure SetFAJnlRange(var FAJnlLine: Record "FA Journal Line"; TemplateName: Code[10]; BatchName: Code[10])
    begin
        with FAJnlLine do begin
            Reset;
            "Journal Template Name" := TemplateName;
            "Journal Batch Name" := BatchName;
            SetRange("Journal Template Name", TemplateName);
            SetRange("Journal Batch Name", BatchName);
            if Find('+') then;
            Init;
        end;
    end;

    procedure SetInsuranceJnlRange(var InsuranceJnlLine: Record "Insurance Journal Line"; TemplateName: Code[10]; BatchName: Code[10])
    begin
        with InsuranceJnlLine do begin
            Reset;
            "Journal Template Name" := TemplateName;
            "Journal Batch Name" := BatchName;
            SetRange("Journal Template Name", TemplateName);
            SetRange("Journal Batch Name", BatchName);
            if Find('+') then;
            Init;
        end;
    end;

    local procedure CalcGLIntegration(BudgetAsset: Boolean; FAPostingType: Enum "FA Journal Line FA Posting Type"): Boolean
    begin
        if BudgetAsset then
            exit(false);
        with DeprBook do
            case FAPostingType of
                FAPostingType::"Acquisition Cost":
                    exit("G/L Integration - Acq. Cost");
                FAPostingType::Depreciation:
                    exit("G/L Integration - Depreciation");
                FAPostingType::"Write-Down":
                    exit("G/L Integration - Write-Down");
                FAPostingType::Appreciation:
                    exit("G/L Integration - Appreciation");
                FAPostingType::"Custom 1":
                    exit("G/L Integration - Custom 1");
                FAPostingType::"Custom 2":
                    exit("G/L Integration - Custom 2");
                FAPostingType::Disposal:
                    exit("G/L Integration - Disposal");
                FAPostingType::Maintenance:
                    exit("G/L Integration - Maintenance");
                FAPostingType::"Salvage Value":
                    exit(false);
            end;
    end;

    [Scope('OnPrem')]
    procedure JnlReclName(DeprBookCode: Code[10]; BudgetFA: Boolean; FAPostType: Enum "FA Journal Line FA Posting Type"; var GenIntegrate: Boolean; var TemplateName: Code[10]; var BatchName: Code[10]; ReclWithoutGenJnl: Boolean)
    var
        GenIntegrate2: Boolean;
    begin
        DeprBook.Get(DeprBookCode);
        if not FAJnlSetup.Get(DeprBookCode, UserId) then
            if not FAJnlSetup.Get(DeprBookCode, '') then
                Error(Text12400, DeprBookCode, UserId);
        GenIntegrate2 := GenIntegrate;
        GenIntegrate := CalcGLIntegration(BudgetFA, FAPostType);
        BatchName2 := BatchName;
        TemplateName2 := TemplateName;
        if ReclWithoutGenJnl then
            GenIntegrate := false;
        if GenIntegrate then begin
            FAJnlSetup.TestField("Gen. Jnl. Template Name");
            FAJnlSetup.TestField("Gen. Jnl. Batch Name");
            TemplateName := FAJnlSetup."Gen. Jnl. Template Name";
            BatchName := FAJnlSetup."Gen. Jnl. Batch Name";
            GenJnlTemplate.Get(TemplateName);
            GenJnlBatch.Get(TemplateName, BatchName);
        end else begin
            FAJnlSetup.TestField("FA Jnl. Template Name");
            FAJnlSetup.TestField("FA Jnl. Batch Name");
            TemplateName := FAJnlSetup."FA Jnl. Template Name";
            BatchName := FAJnlSetup."FA Jnl. Batch Name";
            GenJnlTemplate.Get(TemplateName);
            GenJnlBatch.Get(TemplateName, BatchName);
        end;
        if (GenIntegrate = GenIntegrate2) and
           (BatchName = BatchName2) and
           (TemplateName = TemplateName2)
        then
            Error(Text001, FAJnlSetup.TableName);
    end;
}

