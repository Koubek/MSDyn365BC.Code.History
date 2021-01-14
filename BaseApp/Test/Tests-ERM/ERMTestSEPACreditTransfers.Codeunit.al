codeunit 134403 "ERM Test SEPA Credit Transfers"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [SEPA] [Credit Transfer]
    end;

    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        BankAccount: Record "Bank Account";
        Customer: Record Customer;
        CustomerBankAccount: Record "Customer Bank Account";
        Vendor: Record Vendor;
        VendorBankAccount: Record "Vendor Bank Account";
        BankExportImportSetup: Record "Bank Export/Import Setup";
        Assert: Codeunit Assert;
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        LibraryXPathXMLReader: Codeunit "Library - XPath XML Reader";
        Initialized: Boolean;
        NameTxt: Label 'You Name It';
        AddressTxt: Label 'Privet Drive';
        RemitTxt: Label 'Invoice';
        EURCode: Code[10];
        PostingDocNoWithGapOnNoSeriesErr: Label 'You have one or more documents that must be posted before you post document no. %1 according to your company''s No. Series setup.', Comment = '%1 = Document number to be posted.';
        ExtDocNoTxt: Label 'A123', Locked = true;
        NamespaceTxt: Label 'urn:iso:std:iso:20022:tech:xsd:pain.001.001.03';
        MessageToRecipientNotFoundErr: Label 'The Message To Recipient was not found in the XML file.';
        MessageExceedsLimitErr: Label 'The length of the string is %1, but it must be less than or equal to', Comment = '.';
        TransferDateErr: Label 'The earliest possible transfer date is today.';
        XMLNoChildrenErr: Label 'XML Document has no child nodes.';
        XMLUnknownElementErr: Label 'Unknown element: %1.', Comment = '%1 = xml element name.';
        DefaultLineAmount: Decimal;
        MessageIDErr: Label 'Wrong Message ID in Payment Export Data.';
        PaymentInformationIDErr: Label 'Wrong Payment Information ID in Payment Export Data.';
        EndtoEndIDErr: Label 'Wrong End-to-End ID in Payment Export Data.';
        HasErrorsErr: Label 'The file export has one or more errors.\\For each line to be exported, resolve the errors displayed to the right and then try to export again.';
        CdtrAgtTagErr: Label 'There should not be CdtrAgt tag.';

    [Test]
    [Scope('OnPrem')]
    procedure BasicTestWindowsToASCII()
    var
        StringConversionManagement: Codeunit StringConversionManagement;
        t: Text;
        i: Integer;
        c: Char;
    begin
        for i := 1 to 1119 do
            t := AddCharToText(t, i);
        t := StringConversionManagement.WindowsToASCII(t);
        for i := 1 to 1119 do begin
            c := t[i];
            Assert.IsTrue(c < 128, 'Non-ASCII character returned.');
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestWindowsToASCII16Bit()
    var
        StringConversionManagement: Codeunit StringConversionManagement;
        ActualText: Text;
        t: Text;
    begin
        t := '';
        t := AddCharToText(t, 1040); // ->A
        t := AddCharToText(t, 945); // ->a
        t := AddCharToText(t, 1041); // ->B
        t := AddCharToText(t, 1073); // ->b
        t := AddCharToText(t, 268); // ->C
        t := AddCharToText(t, 967); // ->c
        t := AddCharToText(t, 270); // ->D
        t := AddCharToText(t, 273); // ->d
        t := AddCharToText(t, 280); // ->E
        t := AddCharToText(t, 941); // ->e
        t := AddCharToText(t, 934); // ->F
        t := AddCharToText(t, 1092); // ->f
        t := AddCharToText(t, 1043); // ->G
        t := AddCharToText(t, 285); // ->g
        t := AddCharToText(t, 294); // ->H
        t := AddCharToText(t, 295); // ->h
        t := AddCharToText(t, 306); // ->I
        t := AddCharToText(t, 301); // ->i
        t := AddCharToText(t, 308); // ->J
        t := AddCharToText(t, 309); // ->j
        t := AddCharToText(t, 922); // ->K
        t := AddCharToText(t, 1082); // ->k
        t := AddCharToText(t, 313); // ->L
        t := AddCharToText(t, 318); // ->l
        t := AddCharToText(t, 924); // ->M
        t := AddCharToText(t, 1084); // ->m
        t := AddCharToText(t, 323); // ->N
        t := AddCharToText(t, 957); // ->n
        t := AddCharToText(t, 338); // ->O
        t := AddCharToText(t, 337); // ->o
        t := AddCharToText(t, 936); // ->P
        t := AddCharToText(t, 968); // ->p
        t := AddCharToText(t, 344); // ->R
        t := AddCharToText(t, 961); // ->r
        t := AddCharToText(t, 536); // ->S
        t := AddCharToText(t, 351); // ->s
        t := AddCharToText(t, 1058); // ->T
        t := AddCharToText(t, 1094); // ->t
        t := AddCharToText(t, 360); // ->U
        t := AddCharToText(t, 369); // ->u
        t := AddCharToText(t, 914); // ->V
        t := AddCharToText(t, 1074); // ->v
        t := AddCharToText(t, 372); // ->W
        t := AddCharToText(t, 373); // ->w
        t := AddCharToText(t, 926); // ->X
        t := AddCharToText(t, 958); // ->x
        t := AddCharToText(t, 910); // ->Y
        t := AddCharToText(t, 375); // ->y
        t := AddCharToText(t, 377); // ->Z
        t := AddCharToText(t, 382); // ->z
        t := AddCharToText(t, 1120); // ->.
        ActualText := StringConversionManagement.WindowsToASCII(t);
        Assert.AreEqual(
          'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpRrSsTtUuVvWwXxYyZz.', ActualText, 'Wrong conversion from ' + t);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestWindowsToASCII8Bit()
    var
        StringConversionManagement: Codeunit StringConversionManagement;
        ActualText: Text;
        t: Text;
    begin
        t := '';
        t := AddCharToText(t, 191); // ->?
        t := AddCharToText(t, 193); // ->A
        t := AddCharToText(t, 225); // ->a
        t := AddCharToText(t, 199); // ->C
        t := AddCharToText(t, 231); // ->c
        t := AddCharToText(t, 208); // ->D
        t := AddCharToText(t, 240); // ->d
        t := AddCharToText(t, 202); // ->E
        t := AddCharToText(t, 234); // ->e
        t := AddCharToText(t, 205); // ->I
        t := AddCharToText(t, 237); // ->i
        t := AddCharToText(t, 209); // ->N
        t := AddCharToText(t, 241); // ->n
        t := AddCharToText(t, 213); // ->O
        t := AddCharToText(t, 246); // ->o
        t := AddCharToText(t, 223); // ->s
        t := AddCharToText(t, 222); // ->T
        t := AddCharToText(t, 254); // ->t
        t := AddCharToText(t, 220); // ->U
        t := AddCharToText(t, 250); // ->u
        t := AddCharToText(t, 221); // ->Y
        t := AddCharToText(t, 255); // ->y
        ActualText := StringConversionManagement.WindowsToASCII(t);
        Assert.AreEqual(
          '?AaCcDdEeIiNnOosTtUuYy', ActualText, 'Wrong conversion from ' + t);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestWindowsToASCIIEPC()
    var
        StringConversionManagement: Codeunit StringConversionManagement;
        ActualText: Text;
        t: Text;
    begin
        t := '';
        t := AddCharToText(t, 33); // !->.
        t := AddCharToText(t, 34); // "->space
        t := AddCharToText(t, 35); // #->.
        t := AddCharToText(t, 36); // $->.
        t := AddCharToText(t, 37); // %->.
        t := AddCharToText(t, 38); // &->+
        t := AddCharToText(t, 39); // '->space
        t := AddCharToText(t, 42); // *->.
        t := AddCharToText(t, 59); // ;->,
        t := AddCharToText(t, 60); // <->space
        t := AddCharToText(t, 61); // =->.
        t := AddCharToText(t, 62); // >->space
        t := AddCharToText(t, 64); // @->.
        t := AddCharToText(t, 91); // [->(
        t := AddCharToText(t, 92); // \->/
        t := AddCharToText(t, 93); // ]->)
        t := AddCharToText(t, 94); // ^->.
        t := AddCharToText(t, 95); // _->-
        t := AddCharToText(t, 96); // `->space
        t := AddCharToText(t, 123); // {->(
        t := AddCharToText(t, 124); // |->/
        t := AddCharToText(t, 125); // }->)
        t := AddCharToText(t, 126); // ~->-
        t := AddCharToText(t, 127); // delete->.
        t := AddCharToText(t, 8364); // EURO->E.
        ActualText := StringConversionManagement.WindowsToASCII(t);
        Assert.AreEqual(
          '. ...+ ., . .(/).- (/)-.E', ActualText, 'Wrong conversion from ' + t);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCreditTransferRegister()
    var
        CreditTransferRegister: Record "Credit Transfer Register";
        i: Integer;
    begin
        with CreditTransferRegister do begin
            if FindLast then;
            i := "No.";
            CreateNew('ID123', 'BANK1');
            Assert.AreEqual(i + 1, "No.", 'No. was not incremented correctly.');
            TestField(Identifier, 'ID123');
            TestField("From Bank Account No.", 'BANK1');
            TestField(Status, Status::Canceled);
            SetStatus(Status::"File Created");
            TestField(Status, Status::"File Created");
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCreditTransferEntry()
    var
        CreditTransferEntry: Record "Credit Transfer Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        GenJnlLine: Record "Gen. Journal Line";
        CredTrfRegNo: Integer;
        TrfDate: Date;
        i: Integer;
    begin
        Init;
        GenJnlLine.Init;
        if CustLedgerEntry.FindLast then;
        CustLedgerEntry."Entry No." += 1;
        CustLedgerEntry."Customer No." := Customer."No.";
        CustLedgerEntry."Posting Date" := Today;
        CustLedgerEntry."Document No." := '123';
        CustLedgerEntry.Description := 'Test';
        CustLedgerEntry."Currency Code" := EURCode;
        CustLedgerEntry.Insert;
        if VendorLedgerEntry.FindLast then;
        VendorLedgerEntry."Entry No." += 1;
        VendorLedgerEntry."Vendor No." := Vendor."No.";
        VendorLedgerEntry."Posting Date" := Today;
        VendorLedgerEntry."Document No." := '123';
        VendorLedgerEntry.Description := 'Test';
        VendorLedgerEntry."Currency Code" := EURCode;
        VendorLedgerEntry.Insert;
        with CreditTransferEntry do begin
            if FindLast then;
            CredTrfRegNo := "Credit Transfer Register No.";
            i := "Entry No.";
            TrfDate := Today;
            CreateNew(
              CredTrfRegNo, 0, GenJnlLine."Account Type"::Vendor, VendorLedgerEntry."Vendor No.", VendorLedgerEntry."Entry No.",
              TrfDate, VendorLedgerEntry."Currency Code", 123.45, 'ID123',
              GenJnlLine."Recipient Bank Account", GenJnlLine."Message to Recipient");
            Assert.AreEqual(i + 1, "Entry No.", 'Entry No. was not incremented correctly.');
            TestField("Transfer Date", TrfDate);
            TestField("Credit Transfer Register No.", CredTrfRegNo);
            TestField("Account No.", VendorLedgerEntry."Vendor No.");
            TestField("Applies-to Entry No.", VendorLedgerEntry."Entry No.");
            TestField("Currency Code", VendorLedgerEntry."Currency Code");
            TestField("Transfer Amount", 123.45);
            TestField("Transaction ID", 'ID123');
            VendorLedgerEntry.CalcFields(Amount, "Remaining Amount");
            Assert.AreEqual(Vendor.Name, CreditorName, 'Wrong Creditor Name.');
            Assert.AreEqual(VendorLedgerEntry."Document No.", AppliesToEntryDocumentNo, 'Wrong VLE Doc. No.');
            Assert.AreEqual(VendorLedgerEntry.Description, AppliesToEntryDescription, 'Wrong VLE Description.');
            Assert.AreEqual(VendorLedgerEntry."Posting Date", AppliesToEntryPostingDate, 'Wrong VLE Posting Date.');
            Assert.AreEqual(VendorLedgerEntry."Currency Code", AppliesToEntryCurrencyCode, 'Wrong VLE Currency Code.');
            Assert.AreEqual(VendorLedgerEntry.Amount, AppliesToEntryAmount, 'Wrong VLE Amount.');
            Assert.AreEqual(VendorLedgerEntry."Remaining Amount", AppliesToEntryRemainingAmount, 'Wrong VLE Rem. Amt.');

            CreateNew(
              CredTrfRegNo, 0, GenJnlLine."Account Type"::Customer, CustLedgerEntry."Customer No.", CustLedgerEntry."Entry No.",
              TrfDate, CustLedgerEntry."Currency Code", 123.45, 'ID123',
              GenJnlLine."Recipient Bank Account", GenJnlLine."Message to Recipient");
            CustLedgerEntry.CalcFields(Amount, "Remaining Amount");
            Assert.AreEqual(Customer.Name, CreditorName, 'Wrong Creditor Name.');
            Assert.AreEqual(CustLedgerEntry."Document No.", AppliesToEntryDocumentNo, 'Wrong CLE Doc. No.');
            Assert.AreEqual(CustLedgerEntry.Description, AppliesToEntryDescription, 'Wrong CLE Description.');
            Assert.AreEqual(CustLedgerEntry."Posting Date", AppliesToEntryPostingDate, 'Wrong CLE Posting Date.');
            Assert.AreEqual(CustLedgerEntry."Currency Code", AppliesToEntryCurrencyCode, 'Wrong CLE Currency Code.');
            Assert.AreEqual(CustLedgerEntry.Amount, AppliesToEntryAmount, 'Wrong CLE Amount.');
            Assert.AreEqual(CustLedgerEntry."Remaining Amount", AppliesToEntryRemainingAmount, 'Wrong CLE Rem. Amt.');
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPaymentExportData_InstPrio()
    var
        PaymentExportData: Record "Payment Export Data";
    begin
        with PaymentExportData do begin
            Init;
            Validate("SEPA Instruction Priority", "SEPA Instruction Priority"::NORMAL);
            TestField("SEPA Instruction Priority Text", 'NORM');
            Validate("SEPA Instruction Priority", "SEPA Instruction Priority"::HIGH);
            TestField("SEPA Instruction Priority Text", 'HIGH');
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPaymentExportData_PmtMeth()
    var
        PaymentExportData: Record "Payment Export Data";
    begin
        with PaymentExportData do begin
            Init;
            Validate("SEPA Payment Method", "SEPA Payment Method"::CHK);
            TestField("SEPA Payment Method Text", 'CHK');
            Validate("SEPA Payment Method", "SEPA Payment Method"::TRF);
            TestField("SEPA Payment Method Text", 'TRF');
            Validate("SEPA Payment Method", "SEPA Payment Method"::TRA);
            TestField("SEPA Payment Method Text", 'TRA');
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPaymentExportData_CrgBearer()
    var
        PaymentExportData: Record "Payment Export Data";
    begin
        with PaymentExportData do begin
            Init;
            Validate("SEPA Charge Bearer", "SEPA Charge Bearer"::DEBT);
            TestField("SEPA Charge Bearer Text", 'DEBT');
            Validate("SEPA Charge Bearer", "SEPA Charge Bearer"::CRED);
            TestField("SEPA Charge Bearer Text", 'CRED');
            Validate("SEPA Charge Bearer", "SEPA Charge Bearer"::SHAR);
            TestField("SEPA Charge Bearer Text", 'SHAR');
            Validate("SEPA Charge Bearer", "SEPA Charge Bearer"::SLEV);
            TestField("SEPA Charge Bearer Text", 'SLEV');
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPaymentExportDataIsFieldBlank()
    var
        PaymentExportData: Record "Payment Export Data";
    begin
        with PaymentExportData do begin
            Init;
            "Line No." := 1;
            Assert.IsFalse(IsFieldBlank(FieldNo("Line No.")), FieldName("Line No."));
            "Line No." := 0;
            Assert.IsTrue(IsFieldBlank(FieldNo("Line No.")), FieldName("Line No."));
            Amount := 1;
            Assert.IsFalse(IsFieldBlank(FieldNo(Amount)), FieldName(Amount));
            Amount := 0;
            Assert.IsTrue(IsFieldBlank(FieldNo(Amount)), FieldName(Amount));
            "Sender Bank Account Code" := 'x';
            Assert.IsFalse(IsFieldBlank(FieldNo("Sender Bank Account Code")), FieldName("Sender Bank Account Code"));
            "Sender Bank Account Code" := '';
            Assert.IsTrue(IsFieldBlank(FieldNo("Sender Bank Account Code")), FieldName("Sender Bank Account Code"));
            "Sender Bank Account No." := 'x';
            Assert.IsFalse(IsFieldBlank(FieldNo("Sender Bank Account No.")), FieldName("Sender Bank Account No."));
            "Sender Bank Account No." := '';
            Assert.IsTrue(IsFieldBlank(FieldNo("Sender Bank Account No.")), FieldName("Sender Bank Account No."));
            "Transfer Date" := DMY2Date(1, 1, 2001);
            Assert.IsFalse(IsFieldBlank(FieldNo("Transfer Date")), FieldName("Transfer Date"));
            "Transfer Date" := 0D;
            Assert.IsTrue(IsFieldBlank(FieldNo("Transfer Date")), FieldName("Transfer Date"));
            // an option field always returns FALSE;
            "SEPA Payment Method" := 1;
            Assert.IsFalse(IsFieldBlank(FieldNo("SEPA Payment Method")), FieldName("SEPA Payment Method"));
            "SEPA Payment Method" := 0;
            Assert.IsFalse(IsFieldBlank(FieldNo("SEPA Payment Method")), FieldName("SEPA Payment Method"));
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPaymentExportErrorText()
    var
        PaymentJnlExportErrorText: Record "Payment Jnl. Export Error Text";
        GenJnlLine: Record "Gen. Journal Line";
        i: Integer;
    begin
        if GenJnlLine.FindLast then;
        with PaymentJnlExportErrorText do begin
            SetRange("Journal Template Name", GenJnlLine."Journal Template Name");
            SetRange("Journal Batch Name", GenJnlLine."Journal Batch Name");
            SetRange("Journal Line No.", GenJnlLine."Line No.");
            if FindLast then;
            i := "Line No.";
            CreateNew(GenJnlLine, 'Error 1', '', '');
            FindLast;
            Assert.AreEqual(i + 1, "Line No.", 'Wrong Line No.');
            TestField("Error Text", 'Error 1');
            Assert.IsTrue(GenJnlLine.HasPaymentFileErrors, 'Journal line is missing error text.');
            Assert.IsTrue(JnlLineHasErrors(GenJnlLine), 'Error text not found.');
            DeleteJnlLineErrors(GenJnlLine);
            Assert.IsFalse(GenJnlLine.HasPaymentFileErrors, 'Journal line has an error text.');
            Assert.IsFalse(JnlLineHasErrors(GenJnlLine), 'Error text 1 found.');
            CreateNew(GenJnlLine, 'Error 2', '', '');
            DeleteJnlBatchErrors(GenJnlLine);
            Assert.IsFalse(JnlLineHasErrors(GenJnlLine), 'Error text 2 found.');
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPaymentExportDataCharSetWindows()
    var
        TempPaymentExportData: Record "Payment Export Data" temporary;
        TempPaymentExportRemittanceText: Record "Payment Export Remittance Text" temporary;
    begin
        with TempPaymentExportData do begin
            SetPreserveNonLatinCharacters(true);
            CreatePaymentExportDataCharSetData(TempPaymentExportData);
            Assert.AreEqual(AccentuateText(NameTxt), "Recipient Name", 'Name has been converted.');
            Assert.AreEqual(AccentuateText(AddressTxt), "Recipient Address", 'Address has been converted.');
            GetRemittanceTexts(TempPaymentExportRemittanceText);
            TempPaymentExportRemittanceText.FindFirst;
            Assert.AreEqual(AccentuateText(RemitTxt), TempPaymentExportRemittanceText.Text, 'Remittance text has been converted.');
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPaymentExportDataCharSetASCII()
    var
        TempPaymentExportData: Record "Payment Export Data" temporary;
        TempPaymentExportRemittanceText: Record "Payment Export Remittance Text" temporary;
    begin
        with TempPaymentExportData do begin
            SetPreserveNonLatinCharacters(false);
            CreatePaymentExportDataCharSetData(TempPaymentExportData);
            Assert.AreEqual(Format(NameTxt), "Recipient Name", 'Name has not been converted.');
            Assert.AreEqual(Format(AddressTxt), "Recipient Address", 'Address has not been converted.');
            GetRemittanceTexts(TempPaymentExportRemittanceText);
            TempPaymentExportRemittanceText.FindFirst;
            Assert.AreEqual(Format(RemitTxt), TempPaymentExportRemittanceText.Text, 'Remittance text has not been converted.');
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCompanyInformationSetASCII()
    var
        CompanyInformation: Record "Company Information";
        PaymentExportData: Record "Payment Export Data";
    begin
        with CompanyInformation do begin
            Init;
            Name := CopyStr(AccentuateText(NameTxt), 1, MaxStrLen(Name));
            Address := CopyStr(AccentuateText(AddressTxt), 1, MaxStrLen(Address));
            PaymentExportData.CompanyInformationConvertToLatin(CompanyInformation);
            Assert.AreEqual(Format(NameTxt), Name, 'Name has not been converted.');
            Assert.AreEqual(Format(AddressTxt), Address, 'Address has not been converted.');
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestSEPACreatePayment00100103Success()
    var
        GenJnlLine: Record "Gen. Journal Line";
        TempPaymentExportData: Record "Payment Export Data" temporary;
        CreditTransferRegister: Record "Credit Transfer Register";
        TempPaymentExportRemittanceText: Record "Payment Export Remittance Text" temporary;
        SEPACTFillExportBuffer: Codeunit "SEPA CT-Fill Export Buffer";
    begin
        Init;
        CreateGenJnlLine(GenJnlLine);
        SEPACTFillExportBuffer.FillExportBuffer(GenJnlLine, TempPaymentExportData);
        Assert.AreEqual(1, TempPaymentExportData.Count, 'Wrong number of payment lines created.');
        TempPaymentExportData.GetRemittanceTexts(TempPaymentExportRemittanceText);
        Assert.AreEqual(1, TempPaymentExportRemittanceText.Count, 'Wrong number of remittance lines created.');
        Assert.IsTrue(StrPos(TempPaymentExportRemittanceText.Text, ExtDocNoTxt) > 0, 'Remittance text should contain ext. doc. no.');
        CreditTransferRegister.FindLast;
        CreditTransferRegister.TestField("Created by User", UserId);
        CreditTransferRegister.TestField(Status, CreditTransferRegister.Status::Canceled);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestSEPACreatePayment00100103Failure()
    var
        GenJnlLine: Record "Gen. Journal Line";
        TempPaymentExportData: Record "Payment Export Data" temporary;
        CreditTransferRegister: Record "Credit Transfer Register";
        PaymentJnlExportErrorText: Record "Payment Jnl. Export Error Text";
        SEPACTFillExportBuffer: Codeunit "SEPA CT-Fill Export Buffer";
        LastTransferRegNo: Integer;
    begin
        Init;
        CreateGenJnlLine(GenJnlLine);
        GenJnlLine.Amount := -GenJnlLine.Amount;
        GenJnlLine.Modify;
        if CreditTransferRegister.FindLast then;
        LastTransferRegNo := CreditTransferRegister."No.";

        asserterror SEPACTFillExportBuffer.FillExportBuffer(GenJnlLine, TempPaymentExportData);

        if CreditTransferRegister.FindLast then;
        Assert.AreEqual(LastTransferRegNo, CreditTransferRegister."No.", 'Credit Transfer Reg. was inserted.');

        PaymentJnlExportErrorText.SetRange("Journal Template Name", GenJnlLine."Journal Template Name");
        PaymentJnlExportErrorText.SetRange("Journal Batch Name", GenJnlLine."Journal Batch Name");
        PaymentJnlExportErrorText.SetRange("Journal Line No.", GenJnlLine."Line No.");
        Assert.AreEqual(1, PaymentJnlExportErrorText.Count, 'Wrong number of error texts created.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestSetCustomerAsRecipient()
    var
        Customer: Record Customer;
        CustomerBankAccount: Record "Customer Bank Account";
        PaymentExportData: Record "Payment Export Data";
    begin
        // [FEATURE] [UT]
        // [SCENARIO] Customer Bank Account information should be transferred by PaymentExportData.SetCustomerAsRecipient
        Customer.Init;
        Customer.Name := LibraryUtility.GenerateGUID;
        Customer.Address := LibraryUtility.GenerateGUID;
        Customer.City := LibraryUtility.GenerateGUID;
        Customer.County := LibraryUtility.GenerateGUID;
        Customer."Post Code" := LibraryUtility.GenerateGUID;
        Customer."Country/Region Code" := LibraryUtility.GenerateGUID;

        CustomerBankAccount.Init;
        CustomerBankAccount.Name := LibraryUtility.GenerateGUID;
        CustomerBankAccount.Address := LibraryUtility.GenerateGUID;
        CustomerBankAccount.City := LibraryUtility.GenerateGUID;
        CustomerBankAccount.County := LibraryUtility.GenerateGUID;
        CustomerBankAccount."Post Code" := LibraryUtility.GenerateGUID;
        CustomerBankAccount."Country/Region Code" := LibraryUtility.GenerateGUID;
        CustomerBankAccount."SWIFT Code" := LibraryUtility.GenerateGUID;
        CustomerBankAccount.IBAN := LibraryUtility.GenerateGUID;
        CustomerBankAccount."Bank Clearing Standard" := LibraryUtility.GenerateGUID;
        CustomerBankAccount."Bank Clearing Code" := LibraryUtility.GenerateGUID;

        PaymentExportData.SetCustomerAsRecipient(Customer, CustomerBankAccount);

        PaymentExportData.TestField("Recipient Name", Customer.Name);
        PaymentExportData.TestField("Recipient Address", Customer.Address);
        PaymentExportData.TestField("Recipient City", Customer.City);
        PaymentExportData.TestField("Recipient County", Customer.County);
        PaymentExportData.TestField("Recipient Post Code", Customer."Post Code");
        PaymentExportData.TestField("Recipient Country/Region Code", Customer."Country/Region Code");
        PaymentExportData.TestField("Recipient Email Address", Customer."E-Mail");
        PaymentExportData.TestField("Recipient Bank Name", CustomerBankAccount.Name);
        PaymentExportData.TestField("Recipient Bank Address", CustomerBankAccount.Address);
        PaymentExportData.TestField("Recipient Bank City", CustomerBankAccount.City);
        PaymentExportData.TestField("Recipient Bank County", CustomerBankAccount.County);
        PaymentExportData.TestField("Recipient Bank Post Code", CustomerBankAccount."Post Code");
        PaymentExportData.TestField("Recipient Bank Country/Region", CustomerBankAccount."Country/Region Code");
        PaymentExportData.TestField("Recipient Bank BIC", CustomerBankAccount."SWIFT Code");
        PaymentExportData.TestField("Recipient Bank Acc. No.", CustomerBankAccount.IBAN);
        PaymentExportData.TestField("Recipient Bank Clearing Std.", CustomerBankAccount."Bank Clearing Standard");
        PaymentExportData.TestField("Recipient Bank Clearing Code", CustomerBankAccount."Bank Clearing Code");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestSetVendorAsRecipient()
    var
        Vendor: Record Vendor;
        PaymentExportData: Record "Payment Export Data";
    begin
        // [FEATURE] [UT]
        // [SCENARIO] Vendor Bank Account information should be transferred by PaymentExportData.SetVendorAsRecipient
        Vendor.Init;
        Vendor.Name := LibraryUtility.GenerateGUID;
        Vendor.Address := LibraryUtility.GenerateGUID;
        Vendor.City := LibraryUtility.GenerateGUID;
        Vendor.County := LibraryUtility.GenerateGUID;
        Vendor."Post Code" := LibraryUtility.GenerateGUID;
        Vendor."Country/Region Code" := LibraryUtility.GenerateGUID;

        VendorBankAccount.Init;
        VendorBankAccount.Name := LibraryUtility.GenerateGUID;
        VendorBankAccount.Address := LibraryUtility.GenerateGUID;
        VendorBankAccount.City := LibraryUtility.GenerateGUID;
        VendorBankAccount.County := LibraryUtility.GenerateGUID;
        VendorBankAccount."Post Code" := LibraryUtility.GenerateGUID;
        VendorBankAccount."Country/Region Code" := LibraryUtility.GenerateGUID;
        VendorBankAccount."SWIFT Code" := LibraryUtility.GenerateGUID;
        VendorBankAccount.IBAN := LibraryUtility.GenerateGUID;
        VendorBankAccount."Bank Clearing Standard" := LibraryUtility.GenerateGUID;
        VendorBankAccount."Bank Clearing Code" := LibraryUtility.GenerateGUID;

        PaymentExportData.SetVendorAsRecipient(Vendor, VendorBankAccount);

        PaymentExportData.TestField("Recipient Name", Vendor.Name);
        PaymentExportData.TestField("Recipient Address", Vendor.Address);
        PaymentExportData.TestField("Recipient City", Vendor.City);
        PaymentExportData.TestField("Recipient County", Vendor.County);
        PaymentExportData.TestField("Recipient Post Code", Vendor."Post Code");
        PaymentExportData.TestField("Recipient Country/Region Code", Vendor."Country/Region Code");
        PaymentExportData.TestField("Recipient Email Address", Vendor."E-Mail");
        PaymentExportData.TestField("Recipient Bank Name", VendorBankAccount.Name);
        PaymentExportData.TestField("Recipient Bank Address", VendorBankAccount.Address);
        PaymentExportData.TestField("Recipient Bank City", VendorBankAccount.City);
        PaymentExportData.TestField("Recipient Bank County", VendorBankAccount.County);
        PaymentExportData.TestField("Recipient Bank Post Code", VendorBankAccount."Post Code");
        PaymentExportData.TestField("Recipient Bank Country/Region", VendorBankAccount."Country/Region Code");
        PaymentExportData.TestField("Recipient Bank BIC", VendorBankAccount."SWIFT Code");
        PaymentExportData.TestField("Recipient Bank Acc. No.", VendorBankAccount.IBAN);
        PaymentExportData.TestField("Recipient Bank Clearing Std.", VendorBankAccount."Bank Clearing Standard");
        PaymentExportData.TestField("Recipient Bank Clearing Code", VendorBankAccount."Bank Clearing Code");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestBankAsSenderBank()
    var
        BankAccount: Record "Bank Account";
        PaymentExportData: Record "Payment Export Data";
    begin
        // [FEATURE] [UT]
        // [SCENARIO] Bank Account information should be transferred by PaymentExportData.SetBankAsSenderBank
        BankAccount.Init;
        BankAccount.Name := LibraryUtility.GenerateGUID;
        BankAccount.Address := LibraryUtility.GenerateGUID;
        BankAccount.City := LibraryUtility.GenerateGUID;
        BankAccount.County := LibraryUtility.GenerateGUID;
        BankAccount."Post Code" := LibraryUtility.GenerateGUID;
        BankAccount."No." := LibraryUtility.GenerateGUID;
        BankAccount.IBAN := LibraryUtility.GenerateGUID;
        BankAccount."SWIFT Code" := LibraryUtility.GenerateGUID;
        BankAccount."Bank Clearing Standard" := LibraryUtility.GenerateGUID;
        BankAccount."Bank Clearing Code" := LibraryUtility.GenerateGUID;

        PaymentExportData.SetBankAsSenderBank(BankAccount);

        PaymentExportData.TestField("Sender Bank Name", BankAccount.Name);
        PaymentExportData.TestField("Sender Bank Address", BankAccount.Address);
        PaymentExportData.TestField("Sender Bank City", BankAccount.City);
        PaymentExportData.TestField("Sender Bank County", BankAccount.County);
        PaymentExportData.TestField("Sender Bank Post Code", BankAccount."Post Code");
        PaymentExportData.TestField("Sender Bank Account Code", BankAccount."No.");
        PaymentExportData.TestField("Sender Bank Account No.", BankAccount.IBAN);
        PaymentExportData.TestField("Sender Bank BIC", BankAccount."SWIFT Code");
        PaymentExportData.TestField("Sender Bank Clearing Std.", BankAccount."Bank Clearing Standard");
        PaymentExportData.TestField("Sender Bank Clearing Code", BankAccount."Bank Clearing Code");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCreateXMLDoc()
    var
        GenJnlLine: Record "Gen. Journal Line";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        s: Text;
    begin
        Init;
        CreateGenJnlLine(GenJnlLine);
        TempBlob.CreateOutStream(OutStr);
        XMLPORT.Export(BankAccount.GetPaymentExportXMLPortID, OutStr, GenJnlLine);
        TempBlob.CreateInStream(InStr);
        InStr.ReadText(s);
        Assert.AreEqual('<?xml version="1.0" encoding="UTF-8" standalone="no"?>', s, 'Wrong XML header.');
        InStr.ReadText(s);
        Assert.IsTrue(StrPos(s, 'xmlns="urn:iso:std:iso:20022:tech:xsd:pain.001.001.03"') > 0, 'Wrong XML Instruction.');
        InStr.ReadText(s);
        Assert.AreEqual('  <CstmrCdtTrfInitn>', s, 'Wrong XML root.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestXMLDocGrouping()
    var
        GenJnlLine: Record "Gen. Journal Line";
        TempBlob: Codeunit "Temp Blob";
        XMLDOMManagement: Codeunit "XML DOM Management";
        XMLDoc: DotNet XmlDocument;
        XMLDocNode: DotNet XmlNode;
        XMLNodes: DotNet XmlNodeList;
        XMLNode: DotNet XmlNode;
        OutStr: OutStream;
        InStr: InStream;
        TransferDate: Date;
        ExpectedNoOfGroups: Integer;
        NoOfPmtsPerGroup: Integer;
        NoOfPmtInf: Integer;
        i: Integer;
    begin
        Init;

        ExpectedNoOfGroups := 4;
        NoOfPmtsPerGroup := 5;
        CreateGenJnlLinesDiffDate(GenJnlLine, ExpectedNoOfGroups, NoOfPmtsPerGroup);
        GenJnlLine.FindFirst;
        TransferDate := GenJnlLine."Posting Date";

        TempBlob.CreateOutStream(OutStr);
        XMLPORT.Export(BankAccount.GetPaymentExportXMLPortID, OutStr, GenJnlLine);

        // Validation of elements
        TempBlob.CreateInStream(InStr);
        XMLDOMManagement.LoadXMLDocumentFromInStream(InStr, XMLDoc);
        XMLDocNode := XMLDoc.DocumentElement;
        if not XMLDocNode.HasChildNodes then
            Error(XMLNoChildrenErr);

        XMLNode := XMLDocNode.FirstChild;
        Assert.AreEqual('CstmrCdtTrfInitn', XMLNode.Name, 'CstmrCdtTrfInitn');
        XMLNodes := XMLNode.ChildNodes;
        for i := 0 to XMLNodes.Count - 1 do begin
            XMLNode := XMLNodes.ItemOf(i);
            case XMLNode.Name of
                'GrpHdr':
                    ValidateGrpHdr(XMLNode, GenJnlLine);
                'PmtInf':
                    begin
                        NoOfPmtInf += 1;
                        ValidatePmtInf(XMLNode, NoOfPmtsPerGroup, NoOfPmtsPerGroup * DefaultLineAmount, TransferDate);
                        TransferDate += 1;
                    end;
                else
                    Error(XMLUnknownElementErr, XMLNode.Name);
            end;
        end;

        Assert.AreEqual(ExpectedNoOfGroups, NoOfPmtInf, 'Wrong number of PmtInf nodes.');

        // TFS378393 No empty 'CdtrAgt' tag is exported
        XMLNodes := XMLDoc.GetElementsByTagName('CdtrAgt');
        Assert.AreEqual(0, XMLNodes.Count, CdtrAgtTagErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestXMLMessageToRecipientAppliesToExtDocNoFilled()
    var
        GenJnlLine: Record "Gen. Journal Line";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
    begin
        // [SCENARIO 318397] Exported SEPA CT 001.001.03 contains one Ustrd tag with "Applies-to Ext. Doc. No." and "Message to Recipient"
        Init;
        // [GIVEN] GenJnlLine with "Message to recipient" "Applies-to Ext. Doc. No." not empty
        CreateGenJnlLine(GenJnlLine);
        GenJnlLine.Validate("Message to Recipient", LibraryUtility.GenerateRandomXMLText(140));
        GenJnlLine.Modify(true);

        // [WHEN] The Payment Journal Line is exported
        GenJnlLine.SetRange("Document No.", GenJnlLine."Document No.");
        GenJnlLine.SetRange("Document Type", GenJnlLine."Document Type");
        TempBlob.CreateOutStream(OutStr);
        XMLPORT.Export(BankAccount.GetPaymentExportXMLPortID, OutStr, GenJnlLine);

        // [THEN] The exported file contains one ustrd tag with "Message to recipient" and "Applies-to Ext. Doc. No."
        LibraryXPathXMLReader.InitializeWithBlob(TempBlob, NamespaceTxt);
        LibraryXPathXMLReader.VerifyNodeCountByXPath('//Ustrd', 1);
        Assert.AreEqual(
          CopyStr(StrSubstNo('%1 %2; %3', GenJnlLine."Applies-to Doc. Type", GenJnlLine."Applies-to Ext. Doc. No.", GenJnlLine."Message to Recipient"), 1, 140),
          LibraryXPathXMLReader.GetNodeInnerTextByXPathWithIndex('//Ustrd', 0),
          MessageToRecipientNotFoundErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestXMLMessageToRecipientAppliesToExtDocNoEmpty()
    var
        GenJnlLine: Record "Gen. Journal Line";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
    begin
        // [SCENARIO 318397] Exported SEPA CT 001.001.03 contains one Ustrd tag with "Description" and "Message to Recipient"
        Init;

        // [GIVEN] GenJnlLine with "Message to recipient" and Decsription not empty, "Applies-to Ext. Doc. No." empty
        CreateGenJnlLine(GenJnlLine);
        GenJnlLine.Validate("Message to Recipient", LibraryUtility.GenerateRandomXMLText(140));
        GenJnlLine.Validate("Applies-to Ext. Doc. No.", '');
        GenJnlLine.Modify(true);

        // [WHEN] The Payment Journal Line is exported
        GenJnlLine.SetRange("Document No.", GenJnlLine."Document No.");
        GenJnlLine.SetRange("Document Type", GenJnlLine."Document Type");
        TempBlob.CreateOutStream(OutStr);
        XMLPORT.Export(BankAccount.GetPaymentExportXMLPortID, OutStr, GenJnlLine);

        // [THEN] The exported file contains one ustrd tag with "Message to recipient" and Decsription
        LibraryXPathXMLReader.InitializeWithBlob(TempBlob, NamespaceTxt);
        LibraryXPathXMLReader.VerifyNodeCountByXPath('//Ustrd', 1);
        Assert.AreEqual(
          CopyStr(StrSubstNo('%1; %2', GenJnlLine.Description, GenJnlLine."Message to Recipient"), 1, 140),
          LibraryXPathXMLReader.GetNodeInnerTextByXPathWithIndex('//Ustrd', 0),
          MessageToRecipientNotFoundErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestXMLMessageToRecipientDescriptionEmpty()
    var
        GenJnlLine: Record "Gen. Journal Line";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
    begin
        // [SCENARIO 318397] Exported SEPA CT 001.001.03 contains one Ustrd tag with "Message to Recipient"
        Init;

        // [GIVEN] GenJnlLine with "Message to recipient" not empty, Description and "Applies-to Ext. Doc. No." empty
        CreateGenJnlLine(GenJnlLine);
        GenJnlLine.Validate("Message to Recipient", LibraryUtility.GenerateRandomXMLText(140));
        GenJnlLine.Validate("Applies-to Ext. Doc. No.", '');
        GenJnlLine.Validate(Description, '');
        GenJnlLine.Modify(true);

        // [WHEN] The Payment Journal Line is exported
        GenJnlLine.SetRange("Document No.", GenJnlLine."Document No.");
        GenJnlLine.SetRange("Document Type", GenJnlLine."Document Type");
        TempBlob.CreateOutStream(OutStr);

        XMLPORT.Export(BankAccount.GetPaymentExportXMLPortID, OutStr, GenJnlLine);

        // [THEN] The exported file contains one ustrd tag with "Message to recipient"
        LibraryXPathXMLReader.InitializeWithBlob(TempBlob, NamespaceTxt);
        LibraryXPathXMLReader.VerifyNodeCountByXPath('//Ustrd', 1);
        Assert.AreEqual(
          GenJnlLine."Message to Recipient",
          LibraryXPathXMLReader.GetNodeInnerTextByXPathWithIndex('//Ustrd', 0),
          MessageToRecipientNotFoundErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestXMLMessageToRecipientLimit()
    var
        GenJnlLine: Record "Gen. Journal Line";
        RequiredMessageLength: Integer;
    begin
        // [SCENARIO 109389] Message to recipient cannot contain more than 140 characters
        Init;
        RequiredMessageLength := 141;

        // [GIVEN] A Payment Journal Line
        // [GIVEN] bal. bank account using the SEPA CT export format
        CreateGenJnlLine(GenJnlLine);

        // [WHEN] 141 characters is inserted into "Message to recipient"
        // [THEN] Expect error message, that 141 characters are not allowed into this field.
        asserterror GenJnlLine.Validate("Message to Recipient", LibraryUtility.GenerateRandomXMLText(RequiredMessageLength));

        Assert.ExpectedError(StrSubstNo(MessageExceedsLimitErr, RequiredMessageLength));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PostingDateAfterToday()
    var
        PaymentJnlExportErrorText: Record "Payment Jnl. Export Error Text";
        GenJnlLine: Record "Gen. Journal Line";
        TempPaymentExportData: Record "Payment Export Data" temporary;
        SEPACTFillExportBuffer: Codeunit "SEPA CT-Fill Export Buffer";
    begin
        Init;
        // Setup.
        CreateGenJnlLine(GenJnlLine);
        GenJnlLine."Posting Date" := CalcDate('<1D>', Today);
        GenJnlLine.Modify;
        PaymentJnlExportErrorText.DeleteAll;

        // Exercise.
        SEPACTFillExportBuffer.FillExportBuffer(GenJnlLine, TempPaymentExportData);

        // Verify.
        TempPaymentExportData.TestField("Transfer Date", GenJnlLine."Posting Date");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure DueDateBeforePostingDateBeforeToday()
    var
        PaymentJnlExportErrorText: Record "Payment Jnl. Export Error Text";
        VendLedgerEntry: Record "Vendor Ledger Entry";
        GenJnlLine: Record "Gen. Journal Line";
        TempPaymentExportData: Record "Payment Export Data" temporary;
        SEPACTFillExportBuffer: Codeunit "SEPA CT-Fill Export Buffer";
    begin
        Init;
        // Setup.
        CreateVendorLedgerEntry(VendLedgerEntry, -2);
        CreateGenJnlLine(GenJnlLine);
        GenJnlLine."Posting Date" := CalcDate('<-1D>', Today);
        GenJnlLine.Validate("Applies-to Doc. Type", GenJnlLine."Applies-to Doc. Type"::Invoice);
        GenJnlLine.Validate("Applies-to Doc. No.", VendLedgerEntry."Document No.");
        GenJnlLine.Modify;
        PaymentJnlExportErrorText.DeleteAll;

        // Exercise.
        asserterror SEPACTFillExportBuffer.FillExportBuffer(GenJnlLine, TempPaymentExportData);

        // Verify.
        Assert.ExpectedError(HasErrorsErr);
        CheckPostingDateError(GenJnlLine);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure DueDateBeforeTodayBeforePostingDate()
    var
        VendLedgerEntry: Record "Vendor Ledger Entry";
        GenJnlLine: Record "Gen. Journal Line";
        TempPaymentExportData: Record "Payment Export Data" temporary;
        SEPACTFillExportBuffer: Codeunit "SEPA CT-Fill Export Buffer";
    begin
        Init;
        // Setup.
        CreateVendorLedgerEntry(VendLedgerEntry, -2);
        CreateGenJnlLine(GenJnlLine);
        GenJnlLine."Posting Date" := CalcDate('<1D>', Today);
        GenJnlLine.Validate("Applies-to Doc. Type", GenJnlLine."Applies-to Doc. Type"::Invoice);
        GenJnlLine.Validate("Applies-to Doc. No.", VendLedgerEntry."Document No.");
        GenJnlLine.Modify;

        // Exercise.
        SEPACTFillExportBuffer.FillExportBuffer(GenJnlLine, TempPaymentExportData);

        // Verify.
        TempPaymentExportData.TestField("Transfer Date", GenJnlLine."Posting Date");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure VendorLedgerEntryMarkedAsExportedToFile()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        GenJnlLine: Record "Gen. Journal Line";
        SEPACTExportFile: Codeunit "SEPA CT-Export File";
    begin
        Init;
        // Setup.
        CreateVendorLedgerEntry(VendorLedgerEntry, 0);
        CreateGenJnlLine(GenJnlLine);
        GenJnlLine."Posting Date" := Today;
        GenJnlLine.Validate("Applies-to Doc. Type", GenJnlLine."Applies-to Doc. Type"::Invoice);
        GenJnlLine.Validate("Applies-to Doc. No.", VendorLedgerEntry."Document No.");
        GenJnlLine.Modify;

        // Exercise.
        SEPACTExportFile.EnableExportToServerFile;
        SEPACTExportFile.Run(GenJnlLine);

        // Verify.
        VendorLedgerEntry.Get(VendorLedgerEntry."Entry No.");
        GenJnlLine.Get(GenJnlLine."Journal Template Name", GenJnlLine."Journal Batch Name", GenJnlLine."Line No.");
        Assert.IsTrue(VendorLedgerEntry."Exported to Payment File",
          '''Exported to payment file'' flag not set on the vendor ledger entry.');
        Assert.IsTrue(GenJnlLine."Exported to Payment File",
          '''Exported to payment file'' flag not set on the general journal line.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GenJnlLineDocNoGapWithNoSeries()
    var
        GenJnlLine: Record "Gen. Journal Line";
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        BankAcc: Record "Bank Account";
    begin
        Init;

        // Pre-Setup
        CreateGenJnlLine(GenJnlLine);
        LibraryUtility.CreateNoSeries(NoSeries, true, false, false);
        LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, '', '');

        // Setup
        LibraryERM.CreateBankAccount(BankAcc);
        GenJournalBatch.Validate("No. Series", NoSeries.Code);
        GenJournalBatch.Validate("Allow Payment Export", true);
        GenJournalBatch."Bal. Account Type" := GenJournalBatch."Bal. Account Type"::"Bank Account";
        GenJournalBatch."Bal. Account No." := BankAcc."No.";
        GenJournalBatch.Modify(true);
        GenJnlLine.Validate("Document No.", '1');
        GenJnlLine.Modify(true);

        // Pre-Exercise
        GenJnlLine.SetRange("Journal Template Name", GenJournalTemplate.Name);
        GenJnlLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"Bank Account";
        GenJnlLine."Bal. Account No." := BankAcc."No.";

        // Exercise
        asserterror CODEUNIT.Run(CODEUNIT::"Export Payment File (Yes/No)", GenJnlLine);

        // Verify
        Assert.ExpectedError(StrSubstNo(PostingDocNoWithGapOnNoSeriesErr, GenJnlLine."Document No."));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GenJnlLineDocNoGapWithoutNoSeries()
    var
        GenJnlLine: Record "Gen. Journal Line";
        TempPaymentExportData: Record "Payment Export Data" temporary;
        CreditTransferRegister: Record "Credit Transfer Register";
        SEPACTFillExportBuffer: Codeunit "SEPA CT-Fill Export Buffer";
    begin
        Init;

        // Pre-Setup
        CreateGenJnlLine(GenJnlLine);

        // Setup
        GenJournalBatch.Validate("No. Series", '');
        GenJournalBatch.Modify(true);
        GenJnlLine.Validate("Document No.", '1');
        GenJnlLine.Modify(true);

        // Pre-Exercise
        GenJnlLine.SetRange("Journal Template Name", GenJournalTemplate.Name);
        GenJnlLine.SetRange("Journal Batch Name", GenJournalBatch.Name);

        // Exercise
        SEPACTFillExportBuffer.FillExportBuffer(GenJnlLine, TempPaymentExportData);

        // Verify
        Assert.AreEqual(1, TempPaymentExportData.Count, 'Wrong number of payment lines created.');
        CreditTransferRegister.FindLast;
        CreditTransferRegister.TestField("Created by User", UserId);
        CreditTransferRegister.TestField(Status, CreditTransferRegister.Status::Canceled);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ExportSEPACreditTransferFileToDisk()
    var
        GenJnlLine: Record "Gen. Journal Line";
        CreditTransferRegister: Record "Credit Transfer Register";
        SEPACTExportFile: Codeunit "SEPA CT-Export File";
    begin
        Init;

        // Pre-Setup
        GenJournalBatch.Validate("Bal. Account Type", GenJournalBatch."Bal. Account Type"::"Bank Account");
        GenJournalBatch.Validate("Bal. Account No.", BankAccount."No.");
        GenJournalBatch.Modify(true);

        // Setup
        CreateGenJnlLine(GenJnlLine);

        // Exercise
        SEPACTExportFile.EnableExportToServerFile;
        SEPACTExportFile.Run(GenJnlLine);

        // Pre-Verify
        CreditTransferRegister.SetRange("From Bank Account No.", BankAccount."No.");
        CreditTransferRegister.FindLast;

        // Verify
        CreditTransferRegister.TestField(Status, CreditTransferRegister.Status::"File Created");
        CreditTransferRegister.TestField("Exported File");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPaymentExportDataSetCreditTransferIDs()
    var
        PaymentExportData: Record "Payment Export Data";
        MessageID: Code[20];
        EntryNo: Integer;
        PaymentInformationID: Text[35];
    begin
        // [SCENARIO] Check filling fields in Payment Export Data: fields "Message ID", "Payment Information ID" and "End-to-End ID"
        // [GIVEN] Create new record of Payment Export Data with "Entry No" = "X"
        // [GIVEN] Autogenerated Message ID = "Y"
        EntryNo := LibraryRandom.RandInt(1000);
        MessageID := Format(LibraryRandom.RandInt(1000));
        PaymentExportData.Init;
        PaymentExportData."Entry No." := EntryNo;
        // [WHEN] PaymentExportData.SetCreditTransferIDs("Y")
        PaymentExportData.SetCreditTransferIDs(MessageID);
        // [THEN] "Message ID" = "Y"
        // [THEN] "Payment Information ID" = "Y/X"
        // [THEN] "End-to-End ID" = "Y/X"
        PaymentInformationID := MessageID + '/' + Format(EntryNo);
        with PaymentExportData do begin
            Assert.AreEqual(MessageID, "Message ID", MessageIDErr);
            Assert.AreEqual(PaymentInformationID, "Payment Information ID", PaymentInformationIDErr);
            Assert.AreEqual(PaymentInformationID, "End-to-End ID", EndtoEndIDErr);
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestSetExportFlagOnEmptyGenJnlLineUT()
    var
        GenJournalLine: Record "Gen. Journal Line";
        ExpUserFeedbackGenJnl: Codeunit "Exp. User Feedback Gen. Jnl.";
    begin
        // [FEATURE] [UT]
        // [SCENARIO 363096] Setting Export Flag should not fail if no Gen. Journal Lines found
        // [GIVEN] GenJournal Line with filter only, as it may come from ES
        GenJournalLine.SetFilter("Document No.", LibraryUtility.GenerateGUID);

        // [WHEN] Run setting Export Flag on GenJournal Line
        ExpUserFeedbackGenJnl.SetExportFlagOnGenJnlLine(GenJournalLine);

        // [THEN] Export Flag setting does not fail
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SEPAExportGeneratesCreditTransferEntryForEachAppliedToEntry()
    var
        VendorLedgerEntry: array[2] of Record "Vendor Ledger Entry";
        GenJnlLine: Record "Gen. Journal Line";
        CreditTransferEntry: Record "Credit Transfer Entry";
        SEPACTExportFile: Codeunit "SEPA CT-Export File";
    begin
        // [SCENARIO 305129] When creating SEPA Export File with Gen. Journal Line applied to several Ledger Entries, Credit Transfer Entries get generated for all the Ledger Entries
        Init;

        // [GIVEN] Gen. Journal Line
        CreateGenJnlLine(GenJnlLine);
        GenJnlLine.Validate("Applies-to ID", GenJnlLine."Document No.");
        GenJnlLine.Modify;

        // [GIVEN] Vendor Ledger Entry "1" applied to this Gen. Journal Line
        CreateVendorLedgerEntry(VendorLedgerEntry[1], 0);
        UpdateAppliesToIDOnVendorLedgerEntry(VendorLedgerEntry[1], GenJnlLine."Applies-to ID");

        // [GIVEN] VendorLedgerEntry "2" applied to this Gen. Journal Line
        CreateVendorLedgerEntry(VendorLedgerEntry[2], 0);
        UpdateAppliesToIDOnVendorLedgerEntry(VendorLedgerEntry[2], GenJnlLine."Applies-to ID");

        // [WHEN] SEPA Export File is run
        SEPACTExportFile.EnableExportToServerFile;
        SEPACTExportFile.Run(GenJnlLine);

        // [THEN] Credit Transfer Entry for Vendor Ledger Entry "1" is created
        CreditTransferEntry.SetRange("Applies-to Entry No.", VendorLedgerEntry[1]."Entry No.");
        Assert.RecordIsNotEmpty(CreditTransferEntry);

        // [THEN] Credit Transfer Entry for Vendor Ledger Entry "2" is created
        CreditTransferEntry.SetRange("Applies-to Entry No.", VendorLedgerEntry[2]."Entry No.");
        Assert.RecordIsNotEmpty(CreditTransferEntry);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SEPAExportGenJnlLineTotalExportedAmountIsEqualtToAmount()
    var
        GenJnlLine: array[2] of Record "Gen. Journal Line";
        SEPACTExportFile: Codeunit "SEPA CT-Export File";
    begin
        // [SCENARIO 329011]  When creating SEPA Export File with multiple Gen. Journal Lines applied to Ledger Entries, Gen. Journal Line's TotalExportedAmount is equal to Amount.
        Init;

        // [GIVEN] Two Gen. Journal Line applied to Vendor Ledger Entries.
        CreateGenJnlLineWithVendLedgerEntry(GenJnlLine[1]);
        CreateGenJnlLineWithVendLedgerEntry(GenJnlLine[2]);

        // [WHEN] SEPA Export File is run
        GenJnlLine[1].SetFilter("Line No.", '%1|%2', GenJnlLine[1]."Line No.", GenJnlLine[2]."Line No.");
        SEPACTExportFile.EnableExportToServerFile;
        SEPACTExportFile.Run(GenJnlLine[1]);

        // [THEN] Gen. Journal Line's TotalExportedAmount is equal to Amount
        Assert.AreEqual(GenJnlLine[1].Amount, GenJnlLine[1].TotalExportedAmount, '');
        Assert.AreEqual(GenJnlLine[2].Amount, GenJnlLine[2].TotalExportedAmount, '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SEPAExportNotAppliedGenJnlLineTotalExportedAmountIsEqualtToAmount()
    var
        CreditTransferEntry: Record "Credit Transfer Entry";
        GenJnlLine: Record "Gen. Journal Line";
        SEPACTExportFile: Codeunit "SEPA CT-Export File";
    begin
        // [SCENARIO 329011]  When creating SEPA Export File with Gen. Journal Lines not applied to Ledger Entries, Gen. Journal Line's TotalExportedAmount is equal to Amount.
        Init;
        CreditTransferEntry.SetRange("Account No.", Vendor."No.");
        CreditTransferEntry.DeleteAll;

        // [GIVEN] Gen. Journal Line not applied to Ledger Entries.
        CreateGenJnlLine(GenJnlLine);

        // [WHEN] SEPA Export File is run
        GenJnlLine.SetRange("Line No.", GenJnlLine."Line No.");
        SEPACTExportFile.EnableExportToServerFile;
        SEPACTExportFile.Run(GenJnlLine);

        // [THEN] Gen. Journal Line's TotalExportedAmount is equal to Amount
        Assert.AreEqual(GenJnlLine.Amount, GenJnlLine.TotalExportedAmount, '');
    end;

    local procedure Init()
    var
        NoSeries: Record "No. Series";
        PaymentTerms: Record "Payment Terms";
        PaymentMethod: Record "Payment Method";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"ERM Test SEPA Credit Transfers");
        if Initialized then begin
            GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
            GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
            GenJournalLine.DeleteAll;
            exit;
        end;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"ERM Test SEPA Credit Transfers");

        EURCode := LibraryERM.GetCurrencyCode('EUR');
        DefaultLineAmount := LibraryRandom.RandDec(1000, 2);

        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryERM.CreateBankAccount(BankAccount);
        if EURCode = 'EUR' then
            LibraryERM.CreateExchangeRate(EURCode, CalcDate('<-1Y>', Today), LibraryRandom.RandDec(100, 2),
              LibraryRandom.RandDec(100, 2));

        Vendor.Init;
        Vendor."No." := 'TEST-SEPA';
        if Vendor.Find then
            Vendor.Delete;
        Vendor.Name := 'Microsoft';
        Vendor.Address := 'Microsoft Way 1';
        Vendor.City := 'MS Town';
        Vendor."Post Code" := 'AL-1234';
        LibraryERM.FindPaymentTerms(PaymentTerms);
        Vendor.Validate("Payment Terms Code", PaymentTerms.Code);
        LibraryERM.FindPaymentMethod(PaymentMethod);
        Vendor.Validate("Payment Method Code", PaymentMethod.Code);
        Vendor.Validate("Vendor Posting Group", LibraryPurchase.FindVendorPostingGroup);
        Vendor.Insert;

        LibraryPurchase.CreateVendorBankAccount(VendorBankAccount, Vendor."No.");
        VendorBankAccount.Name := 'Alban Bank No. 1';
        VendorBankAccount."Bank Account No." := '1234567890';
        VendorBankAccount.IBAN := 'AL47 2121 1009 0000 0002 3569 8741';
        VendorBankAccount.Modify;

        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomerBankAccount(CustomerBankAccount, Customer."No.");

        NoSeries.FindFirst;
        CreateBankExpSetup;
        BankAccount."Bank Account No." := '1234 12345678';
        BankAccount.IBAN := 'AL47 2121 1009 0000 0002 3569 8741';
        BankAccount."Credit Transfer Msg. Nos." := NoSeries.Code;
        BankAccount."Payment Export Format" := BankExportImportSetup.Code;
        BankAccount.Modify;
        Initialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"ERM Test SEPA Credit Transfers");
    end;

    local procedure CreateGenJnlLine(var GenJnlLine: Record "Gen. Journal Line")
    begin
        with GenJnlLine do begin
            SetRange("Journal Template Name", GenJournalTemplate.Name);
            SetRange("Journal Batch Name", GenJournalBatch.Name);

            Init;
            LibraryERM.CreateGeneralJnlLine(
              GenJnlLine, GenJournalTemplate.Name, GenJournalBatch.Name,
              "Document Type"::Payment, "Account Type"::Vendor, Vendor."No.", 1);

            if "Applies-to Ext. Doc. No." = '' then
                "Applies-to Ext. Doc. No." := ExtDocNoTxt;
            Validate("Applies-to Doc. Type", "Applies-to Doc. Type"::Invoice);		
            Validate("Recipient Bank Account", VendorBankAccount.Code);
            Validate("Currency Code", EURCode);
            Validate(Amount, DefaultLineAmount);
            Validate("Bal. Account Type", "Bal. Account Type"::"Bank Account");
            Validate("Bal. Account No.", BankAccount."No.");
            Modify;
        end;
    end;

    local procedure CreateGenJnlLinesDiffDate(var GenJnlLine: Record "Gen. Journal Line"; NoOfGroups: Integer; NoOfPmtsPerGroup: Integer)
    var
        i: Integer;
        PostingDate: Date;
    begin
        CreateGenJnlLine(GenJnlLine);
        PostingDate := GenJnlLine."Posting Date";
        for i := 1 to NoOfGroups * NoOfPmtsPerGroup - 1 do begin
            GenJnlLine."Line No." += 10000;
            GenJnlLine.Validate("Posting Date", PostingDate + i div NoOfPmtsPerGroup);
            GenJnlLine.Insert;
        end;
        GenJnlLine.SetRange("Journal Template Name", GenJnlLine."Journal Template Name");
        GenJnlLine.SetRange("Journal Batch Name", GenJnlLine."Journal Batch Name");
    end;

    local procedure CreateGenJnlLineWithVendLedgerEntry(var GenJnlLine: Record "Gen. Journal Line")
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        CreateGenJnlLine(GenJnlLine);
        GenJnlLine.Validate("Applies-to Doc. No.", GenJnlLine."Document No.");
        GenJnlLine.Modify;
        CreateVendorLedgerEntry(VendorLedgerEntry, 0);
        VendorLedgerEntry."Document No." := GenJnlLine."Applies-to Doc. No.";
        VendorLedgerEntry."Document Type" := GenJnlLine."Applies-to Doc. Type";
        VendorLedgerEntry.Modify;
    end;

    local procedure CreateBankExpSetup()
    begin
        with BankExportImportSetup do begin
            Code := 'SEPA-TEST';
            if Find then
                Delete;
            Direction := Direction::Export;
            "Processing Codeunit ID" := CODEUNIT::"SEPA CT-Export File";
            "Processing XMLport ID" := XMLPORT::"SEPA CT pain.001.001.03";
            "Check Export Codeunit" := CODEUNIT::"SEPA CT-Check Line";
            Insert;
        end;
    end;

    local procedure CreatePaymentExportDataCharSetData(var PaymentExportData: Record "Payment Export Data")
    begin
        with PaymentExportData do begin
            Init;
            "Recipient Name" := CopyStr(AccentuateText(NameTxt), 1, MaxStrLen("Recipient Name"));
            "Recipient Address" := CopyStr(AccentuateText(AddressTxt), 1, MaxStrLen("Recipient Address"));
            AddRemittanceText(CopyStr(AccentuateText(RemitTxt), 1, 140));
            Insert(true);
        end;
    end;

    [Normal]
    local procedure CreateVendorLedgerEntry(var VendLedgerEntry: Record "Vendor Ledger Entry"; DateOffset: Integer)
    var
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlBatch: Record "Gen. Journal Batch";
    begin
        LibraryERM.CreateGenJournalBatch(GenJnlBatch, LibraryERM.SelectGenJnlTemplate);
        LibraryERM.CreateGeneralJnlLine(
          GenJnlLine, GenJnlBatch."Journal Template Name", GenJnlBatch.Name,
          GenJnlLine."Document Type"::Invoice, GenJnlLine."Account Type"::Vendor,
          Vendor."No.", -LibraryRandom.RandDec(100, 2));
        GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Bal. Account Type"::"Bank Account");
        GenJnlLine.Validate("Bal. Account No.", BankAccount."No.");
        GenJnlLine.Modify;

        LibraryERM.PostGeneralJnlLine(GenJnlLine);
        VendLedgerEntry.SetRange("Vendor No.", Vendor."No.");
        VendLedgerEntry.SetRange("Document Type", VendLedgerEntry."Document Type"::Invoice);
        VendLedgerEntry.FindLast;
        VendLedgerEntry.Validate("Posting Date", CalcDate('<-30D>', Today));
        VendLedgerEntry.Validate("Due Date", CalcDate('<' + Format(DateOffset) + 'D>', Today));
        VendLedgerEntry.Modify;
    end;

    local procedure AddCharToText(Text: Text; c: Char): Text
    begin
        Text[StrLen(Text) + 1] := c;
        exit(Text);
    end;

    local procedure AccentuateText(Text: Text): Text
    var
        ConvStr: Text;
    begin
        ConvStr := AddCharToText(ConvStr, 238); // i with circomflexe
        ConvStr := AddCharToText(ConvStr, 233); // e with accent egu
        ConvStr := AddCharToText(ConvStr, 259); // a with accent 'Czech'
        ConvStr := AddCharToText(ConvStr, 245); // o with tilde
        ConvStr := AddCharToText(ConvStr, 272); // D Icelandic/Faroese 'ed'
        exit(ConvertStr(Text, 'ieaoD', ConvStr));
    end;

    local procedure CheckPostingDateError(GenJnlLine: Record "Gen. Journal Line")
    var
        PaymentJnlExportErrorText: Record "Payment Jnl. Export Error Text";
    begin
        PaymentJnlExportErrorText.SetRange("Journal Template Name", GenJnlLine."Journal Template Name");
        PaymentJnlExportErrorText.SetRange("Journal Batch Name", GenJnlLine."Journal Batch Name");
        PaymentJnlExportErrorText.SetRange("Journal Line No.", GenJnlLine."Line No.");
        PaymentJnlExportErrorText.SetRange("Error Text", TransferDateErr);
        Assert.AreEqual(1, PaymentJnlExportErrorText.Count, 'Unexpected errors for jnl. line.');
    end;

    local procedure UpdateAppliesToIDOnVendorLedgerEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; NewAppliesToID: Code[50])
    begin
        VendorLedgerEntry.Validate("Applies-to ID", NewAppliesToID);
        VendorLedgerEntry.Modify;
    end;

    local procedure ValidateGrpHdr(var XMLParentNode: DotNet XmlNode; var GenJnlLine: Record "Gen. Journal Line")
    var
        XMLNodes: DotNet XmlNodeList;
        XMLNode: DotNet XmlNode;
        i: Integer;
        dt: DateTime;
    begin
        XMLNodes := XMLParentNode.ChildNodes;
        for i := 0 to XMLNodes.Count - 1 do begin
            XMLNode := XMLNodes.ItemOf(i);
            case XMLNode.Name of
                'MsgId':
                    ;
                'CreDtTm':
                    begin
                        Assert.AreNotEqual('', XMLNode.InnerXml, 'Wrong CreDtTm.');
                        Evaluate(dt, XMLNode.InnerXml, 9);
                        Assert.AreNearlyEqual(0, CurrentDateTime - dt, 60000, 'Wrong CreDtTm.');
                        Assert.AreEqual(19, StrLen(XMLNode.InnerXml), 'Wrong CreDtTm length');
                    end;
                'NbOfTxs':
                    Assert.AreEqual(Format(GenJnlLine.Count, 0, 9), XMLNode.InnerXml, 'Wrong NbOfTxs.');
                'CtrlSum':
                    begin
                        GenJnlLine.CalcSums(Amount);
                        Assert.AreEqual(Format(GenJnlLine.Amount, 0, 9), XMLNode.InnerXml, 'Wrong CtrlSum.');
                    end;
                'InitgPty':
                    ValidatePartyElement(XMLNode);
                else
                    Error(XMLUnknownElementErr, XMLNode.Name);
            end;
        end;
    end;

    local procedure ValidatePartyAddress(var XMLParentNode: DotNet XmlNode)
    var
        XMLNodes: DotNet XmlNodeList;
        XMLNode: DotNet XmlNode;
        i: Integer;
    begin
        XMLNodes := XMLParentNode.ChildNodes;
        for i := 0 to XMLNodes.Count - 1 do begin
            XMLNode := XMLNodes.ItemOf(i);
            case XMLNode.Name of
                'StrtNm', 'PstCd', 'TwnNm', 'Ctry':
                    ;
                else
                    Error(XMLUnknownElementErr, XMLNode.Name);
            end;
        end;
    end;

    local procedure ValidatePartyElement(var XMLParentNode: DotNet XmlNode)
    var
        XMLNodes: DotNet XmlNodeList;
        XMLNode: DotNet XmlNode;
        i: Integer;
    begin
        XMLNodes := XMLParentNode.ChildNodes;
        for i := 0 to XMLNodes.Count - 1 do begin
            XMLNode := XMLNodes.ItemOf(i);
            case XMLNode.Name of
                'Nm':
                    Assert.AreNotEqual('', XMLNode.InnerXml, '');
                'PstlAdr':
                    ValidatePartyAddress(XMLNode);
                'Id':
                    ;
                else
                    Error(XMLUnknownElementErr, XMLNode.Name);
            end;
        end;
    end;

    local procedure ValidatePmtInf(var XMLParentNode: DotNet XmlNode; ExpectedNoOfCdtTrfTxInf: Integer; ExpectedCtrlSum: Decimal; ExpectedDate: Date)
    var
        XMLNodes: DotNet XmlNodeList;
        XMLNode: DotNet XmlNode;
        ActualDate: Date;
        NoOfCdtTrfTxInf: Integer;
        i: Integer;
        CtrlSum: Decimal;
        NbOfTxs: Integer;
    begin
        XMLNodes := XMLParentNode.ChildNodes;
        for i := 0 to XMLNodes.Count - 1 do begin
            XMLNode := XMLNodes.ItemOf(i);
            case XMLNode.Name of
                'PmtInfId', 'BtchBookg', 'PmtTpInf', 'Dbtr', 'DbtrAcct', 'DbtrAgt':
                    ;
                'PmtMtd':
                    Assert.AreEqual('TRF', XMLNode.InnerXml, 'PmtMtd');
                'ChrgBr':
                    Assert.AreEqual('SLEV', XMLNode.InnerXml, 'ChrgBr');
                'CtrlSum':
                    begin
                        Evaluate(CtrlSum, XMLNode.InnerXml, 9);
                        Assert.AreEqual(ExpectedCtrlSum, CtrlSum, 'CtrlSum');
                    end;
                'NbOfTxs':
                    begin
                        Evaluate(NbOfTxs, XMLNode.InnerXml, 9);
                        Assert.AreEqual(ExpectedNoOfCdtTrfTxInf, NbOfTxs, 'NbOfTxs');
                    end;
                'ReqdExctnDt':
                    begin
                        Evaluate(ActualDate, XMLNode.InnerXml, 9);
                        Assert.AreEqual(ExpectedDate, ActualDate, 'ReqdExctnDt');
                    end;
                'CdtTrfTxInf':
                    NoOfCdtTrfTxInf += 1;
                else
                    Error(XMLUnknownElementErr, XMLNode.Name);
            end;
        end;
        Assert.AreEqual(ExpectedNoOfCdtTrfTxInf, NoOfCdtTrfTxInf, 'Wrong number of DrctDbtTxInf nodes.');
    end;
}

