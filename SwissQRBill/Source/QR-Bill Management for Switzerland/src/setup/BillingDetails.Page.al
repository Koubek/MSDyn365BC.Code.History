page 11518 "Swiss QR-Bill Billing Details"
{
    Caption = 'Billing Information Details';
    PageType = List;
    SourceTable = "Swiss QR-Bill Billing Detail";
    SourceTableTemporary = true;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(FormatCodeField; "Format Code")
                {
                    ToolTip = 'Specifies the format code.';
                    ApplicationArea = All;
                }
                field(TagField; "Tag Code")
                {
                    ToolTip = 'Specifies the tag code.';
                    ApplicationArea = All;
                }
                field(ValueField; "Tag Value")
                {
                    ToolTip = 'Specifies the tag value.';
                    ApplicationArea = All;
                }
                field(TypeField; "Tag Type")
                {
                    ToolTip = 'Specifies the tag type.';
                    ApplicationArea = All;
                }
                field(DescriptionField; "Tag Description")
                {
                    ToolTip = 'Specifies the description for the current tag.';
                    ApplicationArea = All;
                }
            }
        }
    }

    internal procedure SetBuffer(var SourceBillingDetail: Record "Swiss QR-Bill Billing Detail")
    begin
        DeleteAll();
        if SourceBillingDetail.FindSet() then
            repeat
                Rec := SourceBillingDetail;
                Insert();
            until SourceBillingDetail.Next() = 0;
        if FindFirst() then;
    end;
}