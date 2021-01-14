page 11000006 "Payment History Line Overview"
{
    Caption = 'Payment History Line Overview';
    Editable = false;
    PageType = List;
    SourceTable = "Payment History Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Identification; Identification)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the identification number for the payment history line.';
                }
                field("Run No."; "Run No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the run number that was given to the entry, based on the number series that is defined in the Run No. Series field.';
                    Visible = false;
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the line''s number.';
                    Visible = false;
                }
                field(Status; Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the status of the payment history line.';
                    Visible = false;
                }
                field("Our Bank"; "Our Bank")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of your bank, through which you want to perform payments or collections.';
                    Visible = false;
                }
                field(Date; Date)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date when you want the payment or collection to be performed.';
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the currency code that the entry is linked to.';
                    Visible = false;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies total amount (including VAT) for the entry.';
                }
                field("Account Type"; "Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of the account you want to perform payments to, or collections from.';
                }
                field("Account No."; "Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the account you want to perform payments to, or collections from.';
                }
                field("Transaction Mode"; "Transaction Mode")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the transaction mode used in telebanking.';
                    Visible = false;
                }
                field("Order"; Order)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the order type of the payment history line.';
                    Visible = false;
                }
                field(Bank; Bank)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number for the bank you want to perform payments to, or collections from.';
                    Visible = false;
                }
                field("Bank Account No."; "Bank Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bank account number you want to perform payments to, or collections from.';
                }
                field("Description 1"; "Description 1")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the payment history line.';
                    Visible = false;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies an additional description of the payment history line.';
                    Visible = false;
                }
                field("Description 3"; "Description 3")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies an additional description of the payment history line.';
                    Visible = false;
                }
                field("Description 4"; "Description 4")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies an additional description of the payment history line.';
                    Visible = false;
                }
                field("Account Holder Name"; "Account Holder Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bank account owner''s name.';
                    Visible = false;
                }
                field("Account Holder Address"; "Account Holder Address")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bank account owner''s address.';
                    Visible = false;
                }
                field("Account Holder Post Code"; "Account Holder Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bank account owner''s postal code.';
                    Visible = false;
                }
                field("Account Holder City"; "Account Holder City")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bank account owner''s city.';
                    Visible = false;
                }
                field("Acc. Hold. Country/Region Code"; "Acc. Hold. Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the country/region code of the bank account holder.';
                    Visible = false;
                }
                field("Nature of the Payment"; "Nature of the Payment")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the nature of the payment for the proposal line.';
                    Visible = false;
                }
                field("Registration No. DNB"; "Registration No. DNB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number issued by the Dutch Central Bank (DNB), to identify a number of types of foreign payments.';
                    Visible = false;
                }
                field("Description Payment"; "Description Payment")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description related to the nature of the payment.';
                    Visible = false;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number the Dutch Central Bank (DNB) issues to transito traders, to identify goods being sold and purchased by these traders.';
                    Visible = false;
                }
                field("Traders No."; "Traders No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number the Dutch Central Bank (DNB) issued to transito trader.';
                    Visible = false;
                }
                field(Urgent; Urgent)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that the payment should be performed urgently.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action("Detail Information")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Detail Information';
                    Image = ViewDetails;
                    RunObject = Page "Payment History Line Detail";
                    RunPageLink = "Run No." = FIELD("Run No."),
                                  "Line No." = FIELD("Line No."),
                                  "Our Bank" = FIELD("Our Bank");
                    RunPageView = SORTING("Our Bank", "Run No.", "Line No.");
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'View invoice-level information for the line.';
                }
                action("Payment History")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Payment History';
                    Image = PaymentHistory;
                    RunObject = Page "Payment History List";
                    RunPageLink = "Our Bank" = FIELD("Our Bank"),
                                  "Run No." = FIELD("Run No.");
                    RunPageView = SORTING("Our Bank", "Run No.");
                    ToolTip = 'View or manage payment information for a each payment or collection that has been generated from a payment or collection proposal. View who and when the payment history was created and exported. Export a payment history, change the status, and view or resolve any payment file errors.';
                }
                action(Dimensions)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to journal lines to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        ShowDimensions;
                    end;
                }
            }
        }
    }
}
