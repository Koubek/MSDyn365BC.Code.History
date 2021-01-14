page 11000012 "Export Protocols"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Export Protocols';
    PageType = List;
    SourceTable = "Export Protocol";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies an export protocol code that you want attached to the entry.';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of what the export protocol stands for.';
                }
                field("Check ID"; "Check ID")
                {
                    ApplicationArea = Basic, Suite;
                    LookupPageID = Objects;
                    ToolTip = 'Specifies the ID for the codeunit used to check the payment histories.';
                }
                field("Check Name"; "Check Name")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    ToolTip = 'Specifies the name of the check codeunit.';
                }
                field("Export Object Type"; "Export Object Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of the Export Object.';
                }
                field("Export ID"; "Export ID")
                {
                    ApplicationArea = Basic, Suite;
                    LookupPageID = Objects;
                    ToolTip = 'Specifies the ID for the batch job used to export payment histories.';
                }
                field("Export Name"; "Export Name")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    ToolTip = 'Specifies the name of the export batch job.';
                }
                field("Docket ID"; "Docket ID")
                {
                    ApplicationArea = Basic, Suite;
                    LookupPageID = Objects;
                    ToolTip = 'Specifies the ID for the report used to inform the contact on combined payments.';
                }
                field("Docket Name"; "Docket Name")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    ToolTip = 'Specifies the name of the docket report.';
                }
                field("Default File Names"; "Default File Names")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the file locations to export payment and collection data to.';
                }
            }
        }
    }

    actions
    {
    }
}
