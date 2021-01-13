report 10913 "IRS notification"
{
    DefaultLayout = RDLC;
    RDLCLayout = './IRSnotification.rdlc';
    Caption = 'IRS notification';

    dataset
    {
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
            column(TodayFormatted; LowerCase(Format(Today, 0, 4)))
            {
            }
            column(CompanyInfoName; CompanyInfo.Name)
            {
            }
            column(CompanyInfoAddress; CompanyInfo.Address)
            {
            }
            column(CompanyInfoPostCodeAndCity; CompanyInfo."Post Code" + ' ' + CompanyInfo.City)
            {
            }
            column(CompanyInfoRegNo; 'Kt. ' + CompanyInfo."Registration No.")
            {
            }
            column(TaxAuthoritiesCaption; TaxAuthoritiesCaptionLbl)
            {
            }
            column(AddrOfTaxAuthoritiesCaption; AddrOfTaxAuthoritiesCaptionLbl)
            {
            }
            column(ZipCodeOfTaxAuthoritiesCaption; ZipCodeOfTaxAuthoritiesCaptionLbl)
            {
            }
            column(IssueOfSingleCopyInvoicesCaption; IssueOfSingleCopyInvoicesCaptionLbl)
            {
            }
            column(NotificationThatTheCompanyCaption; NotificationThatTheCompanyCaptionLbl)
            {
            }
            column(InvInAccordanceCaption; InvInAccordanceCaptionLbl)
            {
            }
            column(VersionOfNavisionCaption; VersionOfNavisionCaptionLbl)
            {
            }
            column(ManagerCaption; ManagerCaptionLbl)
            {
            }
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

    trigger OnInitReport()
    begin
        CompanyInfo.Get;
    end;

    var
        CompanyInfo: Record "Company Information";
        TaxAuthoritiesCaptionLbl: Label 'Tax authorities';
        AddrOfTaxAuthoritiesCaptionLbl: Label 'Address of tax authorities';
        ZipCodeOfTaxAuthoritiesCaptionLbl: Label 'Zip code of tax authorities';
        IssueOfSingleCopyInvoicesCaptionLbl: Label 'Issue of single copy invoices';
        NotificationThatTheCompanyCaptionLbl: Label 'Notification that the company';
        InvInAccordanceCaptionLbl: Label 'intents to utilize the possibility to issue single copy invoices in accordance with IS regulation no. 598/1999';
        VersionOfNavisionCaptionLbl: Label 'It is also confirmed that the company uses a version of Navision that complies with the regulation.';
        ManagerCaptionLbl: Label 'Manager';
}
