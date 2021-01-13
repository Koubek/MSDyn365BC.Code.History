table 12198 "Fattura Code"
{
    Caption = 'Fattura Code';
    DrillDownPageID = "Fattura Codes";
    LookupPageID = "Fattura Codes";

    fields
    {
        field(1; "Code"; Code[4])
        {
            Caption = 'Code';
        }
        field(2; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Payment Method,Payment Terms';
            OptionMembers = "Payment Method","Payment Terms";
        }
        field(3; Description; Text[250])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "Code", Type)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}
