pageextension 4703 "VAT Report Setup Extension" extends "VAT Report Setup"
{
    layout
    {
        addlast(content)
        {
            group(VATGroup)
            {
                Caption = 'VAT Group Management';

                field(VATGroupRole; "VAT Group Role")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies what kind of role the current user has in the VAT group.';
                }
                group(AuthenticationTypeControlOnPrem)
                {
                    Visible = ("VAT Group Role" = "VAT Group Role"::Member) and not IsSaas;
                    ShowCaption = false;
                    field(VATGroupAuthenticationType; "Authentication Type")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies which authentication type will be used to send data to the group representative.';
                    }
                }
                group(AuthenticationTypeControlOnSaas)
                {
                    Visible = ("VAT Group Role" = "VAT Group Role"::Member) and IsSaas;
                    ShowCaption = false;
                    field(VATGroupAuthenticationTypeSaas; AuthenticationTypeSaas)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Authentication Type';
                        ToolTip = 'Specifies which authentication type will be used to send data to the group representative.';
                        trigger OnValidate()
                        begin
                            case AuthenticationTypeSaas of
                                AuthenticationTypeSaas::WebServiceAccessKey:
                                    Rec."Authentication Type" := Rec."Authentication Type"::WebServiceAccessKey;
                                AuthenticationTypeSaas::OAuth2:
                                    Rec."Authentication Type" := Rec."Authentication Type"::OAuth2;
                            end;
                        end;
                    }
                }
                group(MemberIdentifierControl)
                {
                    Visible = ("VAT Group Role" = "VAT Group Role"::Member);
                    ShowCaption = false;
                    field(MemberIdentifier; "Group Member ID")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the current ID of the group member.';
                    }
                }
                group(APIURLControl)
                {
                    Visible = ("VAT Group Role" = "VAT Group Role"::Member);
                    ShowCaption = false;
                    field(APIURL; "Group Representative API URL")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the API URL of the group representative tenant.';
                    }
                }
                group(GroupRepresentativeComapanyControl)
                {
                    Visible = ("VAT Group Role" = "VAT Group Role"::Member);
                    ShowCaption = false;
                    field(GroupRepresentativeCompany; "Group Representative Company")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the company name of the group representative tenant to which the VAT returns will be sent.';
                    }
                }
                group(UserNameControl)
                {
                    Visible = ("VAT Group Role" = "VAT Group Role"::Member) and ("Authentication Type" = "Authentication Type"::WebServiceAccessKey);
                    ShowCaption = false;
                    field(UserName; UserNameText)
                    {
                        ApplicationArea = Basic, Suite;
                        ExtendedDatatype = Masked;
                        Caption = 'User Name';
                        ToolTip = 'Specifies the web service access key of the user in the group representative company.';

                        trigger OnValidate()
                        begin
                            Rec."User Name Key" := Rec.SetSecret(Rec."User Name Key", UserNameText);
                        end;
                    }
                }
                group(WebserviceAccessKeyControl)
                {
                    Visible = ("VAT Group Role" = "VAT Group Role"::Member) and ("Authentication Type" = "Authentication Type"::WebServiceAccessKey);
                    ShowCaption = false;
                    field(WebserviceAccessKey; WebServiceAccessKeyText)
                    {
                        ApplicationArea = Basic, Suite;
                        ExtendedDatatype = Masked;
                        Caption = 'Web Service Access Key';
                        ToolTip = 'Specifies the web service access key of the user in the group representative company.';

                        trigger OnValidate()
                        begin
                            Rec."Web Service Access Key Key" := Rec.SetSecret(Rec."Web Service Access Key Key", WebServiceAccessKeyText);
                        end;
                    }
                }
                group(ClientIdControl)
                {
                    Visible = ("VAT Group Role" = "VAT Group Role"::Member) and ("Authentication Type" = "Authentication Type"::OAuth2);
                    ShowCaption = false;
                    field(ClientId; ClientIDText)
                    {
                        ApplicationArea = Basic, Suite;
                        ExtendedDatatype = Masked;
                        Caption = 'Client ID';
                        ToolTip = 'Specifies the client ID of the Azure AD application used to access the API.';

                        trigger OnValidate()
                        begin
                            Rec."Client ID Key" := Rec.SetSecret(Rec."Client ID Key", ClientIDText);
                        end;
                    }
                }
                group(ClientSecretControl)
                {
                    Visible = ("VAT Group Role" = "VAT Group Role"::Member) and ("Authentication Type" = "Authentication Type"::OAuth2);
                    ShowCaption = false;
                    field(ClientSecret; ClientSecretText)
                    {
                        ApplicationArea = Basic, Suite;
                        ExtendedDatatype = Masked;
                        Caption = 'Client Secret';
                        ToolTip = 'Specifies the client secret of the Azure AD application used to access the API.';

                        trigger OnValidate()
                        begin
                            Rec."Client Secret Key" := Rec.SetSecret(Rec."Client Secret Key", ClientSecretText);
                        end;
                    }
                }
                group(AuthorityURLControl)
                {
                    Visible = ("VAT Group Role" = "VAT Group Role"::Member) and ("Authentication Type" = "Authentication Type"::OAuth2);
                    ShowCaption = false;
                    field(AuthorityURL; "Authority URL")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the authority URL of the OAuth authority used to grant access tokens.';
                    }
                }
                group(ResourceURLControl)
                {
                    Visible = ("VAT Group Role" = "VAT Group Role"::Member) and ("Authentication Type" = "Authentication Type"::OAuth2);
                    ShowCaption = false;
                    field(ResourceURL; "Resource URL")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the resource URL of the Azure AD application to which access will be granted.';
                    }
                }
                group(RedirectURLControl)
                {
                    Visible = ("VAT Group Role" = "VAT Group Role"::Member) and ("Authentication Type" = "Authentication Type"::OAuth2);
                    ShowCaption = false;
                    field(RedirectURL; "Redirect URL")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the OAuth2 redirect URL of the Azure AD application used to access the API.';
                    }
                }

                group(ApprovedMembersControl)
                {
                    Visible = ("VAT Group Role" = "VAT Group Role"::Representative);
                    ShowCaption = false;

                    field(ApprovedMembers; "Approved Members")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the number of approved members that are allowed to submit their VAT returns. Clicking on this number will open the Approved Members page.';
                        Visible = ("VAT Group Role" = "VAT Group Role"::Representative);
                        DrillDown = true;
                        DrillDownPageId = "VAT Group Approved Member List";

                    }
                }
            }
        }
    }

    actions
    {
        addlast(Processing)
        {
            action(RenewToken)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Renew OAuth2 Token';
                ToolTip = 'Initiates a new OAuth2 authetication flow which will result in getting a new token. This should be used if the the previous token has expired or can no longer be used.';
                Promoted = true;
                PromotedCategory = Process;
                Image = AuthorizeCreditCard;
                Visible = ("Authentication Type" = "Authentication Type"::OAuth2) and ("VAT Group Role" = "VAT Group Role"::Member);

                trigger OnAction()
                var
                    VATGroupCommunication: Codeunit "VAT Group Communication";
                begin
                    VATGroupCommunication.GetBearerToken(Rec.GetSecret(Rec."Client ID Key"), Rec.GetSecret(Rec."Client Secret Key"), Rec."Authority URL", Rec."Redirect URL", Rec."Resource URL");
                end;
            }
        }
    }

    var
        EnvironmentInformation: Codeunit "Environment Information";
        AuthenticationTypeSaas: Enum "VAT Group Authentication Type Saas";
        [NonDebuggable]
        ClientSecretText: Text;
        [NonDebuggable]
        ClientIDText: Text;
        [NonDebuggable]
        UserNameText: Text;
        [NonDebuggable]
        WebServiceAccessKeyText: Text;
        IsSaas: Boolean;

    trigger OnOpenPage()
    begin
        ClientSecretText := Rec.GetSecret(Rec."Client Secret Key");
        ClientIDText := Rec.GetSecret(Rec."Client ID Key");
        UserNameText := Rec.GetSecret(Rec."User Name Key");
        WebServiceAccessKeyText := Rec.GetSecret(Rec."Web Service Access Key Key");
        IsSaas := EnvironmentInformation.IsSaaS();

        if (Rec."VAT Group Role" = Rec."VAT Group Role"::Member) and IsNullGuid(Rec."Group Member ID") then begin
            Rec."Group Member ID" := CreateGuid();
            Rec.Modify();
        end;
    end;
}