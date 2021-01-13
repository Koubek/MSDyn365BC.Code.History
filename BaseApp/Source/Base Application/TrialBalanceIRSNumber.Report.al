report 10912 "Trial Balance - IRS Number"
{
    DefaultLayout = RDLC;
    RDLCLayout = './TrialBalanceIRSNumber.rdlc';
    ApplicationArea = Basic, Suite;
    Caption = 'Trial Balance - IRS Number';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("G/L Account"; "G/L Account")
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Account Type", "Date Filter", "Global Dimension 1 Filter", "Global Dimension 2 Filter";
            column(TodayFormatted; Format(Today, 0, 4))
            {
            }
            column(PeriodText; 'Period:  ' + PeriodText)
            {
            }
            column(CompanyName; COMPANYPROPERTY.DisplayName)
            {
            }
            column(GLFilter; "G/L Account".TableName + ': ' + GLFilter)
            {
            }
            column(EmptyString; '')
            {
            }
            column(TrialBalanceIRSNumberCaption; TrialBalanceIRSNumberCaptionLbl)
            {
            }
            column(PageNoCaption; PageNoCaptionLbl)
            {
            }
            column(NetChangeCaption; NetChangeCaptionLbl)
            {
            }
            column(StatusCaption; StatusCaptionLbl)
            {
            }
            column(NoCaption_GLAcc; FieldCaption("No."))
            {
            }
            column(GLAccNameCaption; GLAccNameCaptionLbl)
            {
            }
            column(DebitCaption; DebitCaptionLbl)
            {
            }
            column(CreditCaption; CreditCaptionLbl)
            {
            }
            column(IRSNumberCaption; IRSNumberCaptionLbl)
            {
            }
            dataitem(BlankLineCounter; "Integer")
            {
                DataItemTableView = SORTING(Number);

                trigger OnPreDataItem()
                begin
                    SetRange(Number, 1, "G/L Account"."No. of Blank Lines");
                end;
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                column(No_GLAcc; "G/L Account"."No.")
                {
                }
                column(GLAccName; PadStr('', "G/L Account".Indentation * 2) + "G/L Account".Name)
                {
                }
                column(NetChange_GLAcc; "G/L Account"."Net Change")
                {
                }
                column(NegativeNetChange_GLAcc; -"G/L Account"."Net Change")
                {
                }
                column(BalanceAtDate_GLAcc; "G/L Account"."Balance at Date")
                {
                }
                column(NegativeBalanceAtDate_GLAcc; -"G/L Account"."Balance at Date")
                {
                }
                column(IRSNumber_GLAcc; "G/L Account"."IRS Number")
                {
                }
            }

            trigger OnAfterGetRecord()
            begin
                CalcFields("Net Change", "Balance at Date");
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        GLFilter := "G/L Account".GetFilters;
        PeriodText := "G/L Account".GetFilter("Date Filter");
    end;

    var
        GLFilter: Text[250];
        PeriodText: Text[30];
        TrialBalanceIRSNumberCaptionLbl: Label 'Trial Balance - IRS Number';
        PageNoCaptionLbl: Label 'Page';
        NetChangeCaptionLbl: Label 'Net Change';
        StatusCaptionLbl: Label 'Status';
        GLAccNameCaptionLbl: Label 'Name';
        DebitCaptionLbl: Label 'Debit';
        CreditCaptionLbl: Label 'Credit';
        IRSNumberCaptionLbl: Label 'IRS Number';
}
