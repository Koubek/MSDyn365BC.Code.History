page 12113 "Withholding Tax List"
{
    ApplicationArea = Basic, Suite;
    Caption = 'WithHolding Tax';
    CardPageID = "Withholding Tax Card";
    Editable = false;
    PageType = List;
    SourceTable = "Withholding Tax";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Month; Month)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the month of the withholding tax entry in numeric format.';
                }
                field(Year; Year)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the year of the withholding tax entry in numeric format. ';
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the transaction date of the source document that generated the withholding tax entry.';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a unique identification number that refers to the source document that generated the withholding tax entry.';
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies an identification number, using the numbering system of the vendor, that links the vendor''s source document to the withholding tax entry.';
                }
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the unique identification number of the vendor that is related to the withholding tax entry.';
                }
                field("Related Date"; "Related Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the transaction date of the purchase that generated the withholding tax entry.';
                }
                field("Payment Date"; "Payment Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date that the withholding tax amount was paid to the tax authority.';
                }
                field("Total Amount"; "Total Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total amount of the original purchase that is subject to withholding tax.';
                }
                field("Base - Excluded Amount"; "Base - Excluded Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount of the original purchase that is excluded from the withholding tax calculation, based on exclusions allowed by law.';
                }
                field("Non Taxable Amount By Treaty"; "Non Taxable Amount By Treaty")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount of the original purchase that is excluded from the withholding tax calculation based on residency. ';
                }
                field("Non Taxable Amount %"; "Non Taxable Amount %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the percent of the original purchase transaction that is not taxable due to provisions in the law.';
                }
                field("Non Taxable Amount"; "Non Taxable Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount of the original purchase that is not taxable due to provisions in the law.';
                }
                field("Taxable Base"; "Taxable Base")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount of the original purchase that is subject to withholding tax after non-taxable and excluded amounts have been subtracted.';
                }
                field("Withholding Tax Code"; "Withholding Tax Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the withholding code that is applied to this purchase. ';
                }
                field("Tax Code"; "Tax Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a unique four-digit code that is used to reference the fiscal withholding tax that is applied to this entry.';
                }
                field("Withholding Tax %"; "Withholding Tax %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the percentage of the purchase that is subject to withholding tax.';
                }
                field("Withholding Tax Amount"; "Withholding Tax Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount of withholding tax for this purchase. ';
                }
                field("Source-Withholding Tax"; "Source-Withholding Tax")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the withholding tax is an official tax governed by the Italian tax authority.';
                }
                field(Reason; Reason)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the reason code.';
                }
                field(Reported; Reported)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the withholding tax amount from this entry has been reported to the tax authority.';
                }
                field(Paid; Paid)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the withholding tax amount for this entry has been paid to the tax authority.';
                }
                field("Recipient May Report Income"; "Recipient May Report Income")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the vendor can report income based on this purchase.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Navigate)
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Navigate';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'View the number and type of entries that have the same document number or posting date.';

                trigger OnAction()
                begin
                    Navigate;
                end;
            }
        }
    }
}
