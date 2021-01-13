page 2000000 "EB Payment Journal Templates"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Payment Journal Templates';
    PageType = List;
    SourceTable = "Payment Journal Template";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Name; Name)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the payment journal template.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the payment journal template.';
                }
                field("Bank Account"; "Bank Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the bank account on which you want the payments in this journal to be made.';
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the reason code, a supplementary source code that enables you to trace the entry.';
                }
                field("Source Code"; "Source Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source code that specifies where the entry was created.';
                }
                field("Page ID"; "Page ID")
                {
                    ApplicationArea = Basic, Suite;
                    LookupPageID = Objects;
                    ToolTip = 'Specifies the window number used for this journal template.';
                    Visible = false;
                }
                field("Page Name"; "Page Name")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    ToolTip = 'Specifies the name of the window for this journal template.';
                    Visible = false;
                }
                field("Test Report ID"; "Test Report ID")
                {
                    ApplicationArea = Basic, Suite;
                    LookupPageID = Objects;
                    ToolTip = 'Specifies the ID of the test report, which can be printed by choosing the function Print, Test Report.';
                    Visible = false;
                }
                field("Test Report Name"; "Test Report Name")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    ToolTip = 'Specifies the name of the test report that can be printed by choosing the function Print, Test Report.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Te&mplate")
            {
                Caption = 'Te&mplate';
                action(Batches)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Batches';
                    Image = ChangeBatch;
                    RunObject = Page "EB Payment Journal Batches";
                    RunPageLink = "Journal Template Name" = FIELD(Name);
                    ToolTip = 'View or edit multiple journals for a specific template. You can use batches when you need multiple journals of a certain type.';
                }
            }
        }
    }
}
