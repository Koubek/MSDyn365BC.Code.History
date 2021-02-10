codeunit 4700 "VAT Group Communication"
{
    var
        VATReportSetup: Record "VAT Report Setup";
        AuthFlow: DotNet ALAzureAdCodeGrantFlow;
        NoVATSetupErr: Label 'The VAT Report Setup could not be found.';
        BearerTokenFromCacheErr: Label 'The Bearer token could not be retrieved from cache. Please refresh the VAT Group bearer token by logging in the %1 page', Comment = '%1 the caption of a page.';
        OAuthFailedNoErr: label 'Authorization has failed with an unexpected error.';
        OAuthFailedErr: Label 'Authorization has failed with the error %1', Comment = '%1 is the error description.';
        URLAppendixCompanyLbl: Label '/api/microsoft/vatgroup/v1.0/companies(name=''%1'')', Locked = true;
        URLAppendixLbl: Label '/api/microsoft/vatgroup/v1.0', Locked = true;
        URLAppendixCompany2018Lbl: Label '/api/v1.0/companies(name=''%1'')', Locked = true;
        URLAppendix2018Lbl: Label '/api/v1.0', Locked = true;
        URLAppendixCompany2017Lbl: Label '/OData/Company(''%1'')', Locked = true;
        URLAppendix2017Lbl: Label '/OData', Locked = true;
        VATGroupSubmissionStatusEndpointTxt: Label '/vatGroupSubmissionStatus?$filter=no eq ''%1'' and groupMemberId eq %2&$select=no,status', Locked = true;
        VATGroupSubmissionStatusEndpoint2017Txt: Label '/vatGroupSubmissionStatus?$filter=no eq ''%1'' and groupMemberId eq (guid''%2'')&$select=no,status&$format=json', Locked = true;
        InvalidSyntaxErr: Label 'Bad Request: the server could not understand the request due to invalid syntax.'; // 400
        UnauthorizedErr: Label 'Unauthorized: authentication credentials are not valid.'; // 401
        ForbiddenErr: Label 'Forbidden: missing permissions to access the requested resource.'; // 403
        NotFoundErr: Label 'Not Found: cannot locate the requested resource.'; // 404 
        InternalServerErrorErr: Label 'Internal Server Error: the server cannot process the request.'; // 500
        ServiceUnavailableErr: Label 'Service Unavailable: the server is not available, try again later.'; // 503
        GeneralHttpErr: Label 'Something went wrong, try again later.';
        // Telemetry
        VATGroupTok: Label 'VATGroupTelemetryCategoryTok', Locked = true;
        HttpSuccessMsg: Label 'The http request was successful and the resource was created', Locked = true;
        BearerTokenSuccessMsg: Label 'The OAuth2 authentication was successfull, a token has been issued.', Locked = true;
        HttpErrorMsg: Label 'Error Code: %1, Error Msg: %2', Locked = true;
        AuthorizationCodeErr: Label 'The OAuth2 authentication code retrieved is empty.', Locked = true;
        MissingClientIdRedirectUrlErr: Label 'The authorization request URL for the OAuth2 Grant flow cannot be constructed because of missing ClientId or RedirectUrl', Locked = true;
        AuthRequestUrlTxt: Label 'The authentication request URL %1 has been succesfully retrieved.', Comment = '%1=Authentication request URL';
        Oauth2CategoryLbl: Label 'OAuth2', Locked = true;
        RedirectUrlTxt: Label 'The defined redirectURL is: %1', Comment = '%1 = The redirect URL', Locked = true;
        RedirectURLMissingErr: Label 'The redirect URL is missing, the OAuth2 token cannot be retrieved. Please fill in the Redirect URL and try again.';
        VATReportSetupIsLoaded: Boolean;

    [TryFunction]
    internal procedure Send(Method: Text; Endpoint: Text; Content: Text; var HttpResponseBodyText: Text; IsBatch: Boolean)
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
    begin
        CheckLoadVATReportSetup();

        HttpRequestMessage.Method(Method);
        if IsBatch then
            HttpRequestMessage.SetRequestUri(PrepareBatchURI(Endpoint))
        else
            HttpRequestMessage.SetRequestUri(PrepareURI(Endpoint));
        PrepareHeaders(HttpRequestMessage, IsBatch);
        PrepareContent(HttpRequestMessage, Content);

        if VATReportSetup."Authentication Type" = VATReportSetup."Authentication Type"::WindowsAuthentication then
            HttpClient.UseDefaultNetworkWindowsAuthentication();

        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);
        HttpResponseMessage.Content().ReadAs(HttpResponseBodyText);
        HandleHttpResponse(HttpResponseMessage);
    end;

    local procedure HandleHttpResponse(HttpResponseMessage: HttpResponseMessage)
    var
        FriendlyErrorMsg: Text;
        ErrorMsg: Text;
    begin
        case Format(HttpResponseMessage.HttpStatusCode()) of
            '200':
                begin
                    SendTraceTag('0000D7D', VATGroupTok, VERBOSITY::Normal, HttpSuccessMsg, DATACLASSIFICATION::SystemMetadata);
                    exit;
                end;
            '201':
                begin
                    SendTraceTag('0000DAE', VATGroupTok, VERBOSITY::Normal, HttpSuccessMsg, DATACLASSIFICATION::SystemMetadata);
                    exit;
                end;
            '400':
                FriendlyErrorMsg := InvalidSyntaxErr;
            '401':
                FriendlyErrorMsg := UnauthorizedErr;
            '403':
                FriendlyErrorMsg := ForbiddenErr;
            '404':
                FriendlyErrorMsg := NotFoundErr;
            '500':
                FriendlyErrorMsg := InternalServerErrorErr;
            '503':
                FriendlyErrorMsg := ServiceUnavailableErr;
            else
                FriendlyErrorMsg := GeneralHttpErr;
        end;

        HttpResponseMessage.Content().ReadAs(ErrorMsg);
        SendTraceTag('0000D7E', VATGroupTok, VERBOSITY::Error, StrSubstNo(HttpErrorMsg, HttpResponseMessage.HttpStatusCode(), ErrorMsg), DATACLASSIFICATION::SystemMetadata);
        Error(FriendlyErrorMsg);
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    internal procedure GetBearerToken(ClientId: Text; ClientSecret: Text; AuthorityURL: Text; RedirectURL: Text; ResourceURL: Text)
    var
        BearerToken: Text;
        AuthCode: Text;
        AuthCodeErr: Text;
        AuthRequestUrl: Text;
        State: Text;
    begin
        //get authcode using addin.
        InitializeAuthFlow(RedirectURL);
        AuthRequestUrl := PrepareAuthRequestUrl(ClientId, AuthorityURL, RedirectURL, State, ResourceUrl);
        SetPropertiesBasedOnAuthRequestUrlAndRunOAuth2ControlAddIn(AuthRequestUrl, State, AuthCode, AuthCodeErr);
        BearerToken := AuthFlow.ALAcquireTokenByAuthorizationCodeWithCredentials(AuthCode, ClientId, ClientSecret, ResourceURL);

        if BearerToken <> '' then begin
            Message(BearerTokenSuccessMsg);
            exit;
        end;

        if AuthCodeErr = '' then
            Error(OAuthFailedNoErr)
        else
            Error((StrSubstNo(OAuthFailedErr, AuthCodeErr)));
    end;

    [NonDebuggable]
    [Scope('OnPrem')]
    internal procedure GetOAuthProperties(AuthorizationCode: Text; var CodeOut: Text; var StateOut: Text)
    begin
        if AuthorizationCode = '' then begin
            SendTraceTag('0000DMC', Oauth2CategoryLbl, Verbosity::Error, AuthorizationCodeErr, DataClassification::SystemMetadata);
            exit;
        end;

        if AuthorizationCode.EndsWith('#') then
            AuthorizationCode := CopyStr(AuthorizationCode, 1, StrLen(AuthorizationCode) - 1);

        CodeOut := GetPropertyFromCode(AuthorizationCode, 'code');
        StateOut := GetPropertyFromCode(AuthorizationCode, 'state');
    end;

    [NonDebuggable]
    [Scope('OnPrem')]
    internal procedure PrepareAuthRequestUrl(ClientId: Text; Url: Text; RedirectUrl: Text; var State: Text; ResourceUrl: Text): Text
    var
        AuthRequestUrl: Text;
    begin
        if (ClientId = '') or (RedirectUrl = '') then begin
            SendTraceTag('0000DMD', Oauth2CategoryLbl, Verbosity::Error, MissingClientIdRedirectUrlErr, DataClassification::SystemMetadata);
            exit('');
        end;

        State := Format(CreateGuid(), 0, 4);

        AuthRequestUrl := Url + '?client_id=' + ClientId + '&redirect_uri=' + RedirectUrl + '&state=' + State + '&response_type=code&response_mode=query';

        if ResourceUrl <> '' then
            AuthRequestUrl := AuthRequestUrl + '&resource=' + ResourceUrl;

        AuthRequestUrl := AuthRequestUrl + '&prompt=login';

        SendTraceTag('0000DME', Oauth2CategoryLbl, Verbosity::Normal, StrSubstNo(AuthRequestUrlTxt, AuthRequestUrl), DataClassification::AccountData);
        exit(AuthRequestUrl);
    end;

    [NonDebuggable]
    local procedure GetBearerTokenFromCache(): Text
    var
        VATReportSetupPage: Page "VAT Report Setup";
        BearerToken: Text;
    begin
        CheckLoadVATReportSetup();

        InitializeAuthFlow(VATReportSetup."Redirect URL");
        BearerToken := AuthFlow.ALAcquireTokenFromCacheWithCredentials(VATReportSetup.GetSecret(VATReportSetup."Client ID Key"),
            VATReportSetup.GetSecret(VATReportSetup."Client Secret Key"),
            VATReportSetup."Resource URL");

        if BearerToken = '' then
            Error(BearerTokenFromCacheErr, VATReportSetupPage.Caption());

        exit(BearerToken);
    end;

    [NonDebuggable]
    local procedure PrepareHeaders(HttpRequestMessage: HttpRequestMessage; IsBatch: Boolean)
    var
        Base64Convert: Codeunit "Base64 Convert";
        HttpRequestHeaders: HttpHeaders;
        Base64AuthHeader: Text;
    begin
        HttpRequestMessage.GetHeaders(HttpRequestHeaders);

        HttpRequestHeaders.Add('Accept', 'application/json');

        if VATReportSetup."Authentication Type" = VATReportSetup."Authentication Type"::WebServiceAccessKey then begin
            Base64AuthHeader := Base64Convert.ToBase64(VATReportSetup.GetSecret(VATReportSetup."User Name Key") + ':' + VATReportSetup.GetSecret(VATReportSetup."Web Service Access Key Key"));
            HttpRequestHeaders.Add('Authorization', 'Basic ' + Base64AuthHeader);
        end;

        if VATReportSetup."Authentication Type" = VATReportSetup."Authentication Type"::OAuth2 then
            HttpRequestHeaders.Add('Authorization', 'Bearer ' + GetBearerTokenFromCache());

        if IsBatch then
            HttpRequestHeaders.Add('Prefer', 'odata.continue-on-error');
    end;

    local procedure PrepareContent(HttpRequestMessage: HttpRequestMessage; Content: Text)
    var
        HttpContent: HttpContent;
        HttpContentHeaders: HttpHeaders;
    begin
        if Content = '' then
            exit;

        HttpContent.GetHeaders(HttpContentHeaders);
        HttpContent.WriteFrom(Content);
        HttpContentHeaders.Remove('Content-Type');
        HttpContentHeaders.Add('Content-Type', 'application/json');
        HttpRequestMessage.Content(HttpContent);
    end;

    [NonDebuggable]
    local procedure GetPropertyFromCode(CodeTxt: Text; Property: Text): Text
    var
        PosProperty: Integer;
        PosValue: Integer;
        PosEnd: Integer;
    begin
        PosProperty := StrPos(CodeTxt, Property);
        if PosProperty = 0 then
            exit('');
        PosValue := PosProperty + StrPos(CopyStr(Codetxt, PosProperty), '=');
        PosEnd := PosValue + StrPos(CopyStr(CodeTxt, PosValue), '&');

        if PosEnd = PosValue then
            exit(CopyStr(CodeTxt, PosValue, StrLen(CodeTxt) - 1));
        exit(CopyStr(CodeTxt, PosValue, PosEnd - PosValue - 1));
    end;

    local procedure InitializeAuthFlow(RedirectURL: Text)
    var
        Uri: DotNet Uri;
    begin
        if RedirectURL = '' then
            Error(RedirectURLMissingErr)
        else
            SendTraceTag('0000DMF', Oauth2CategoryLbl, Verbosity::Normal, StrSubstNo(RedirectUrlTxt, RedirectUrl), DataClassification::AccountData);

        AuthFlow := AuthFlow.ALAzureAdCodeGrantFlow(Uri.Uri(RedirectURL));
    end;

    [NonDebuggable]
    [Scope('OnPrem')]
    [TryFunction]
    internal procedure SetPropertiesBasedOnAuthRequestUrlAndRunOAuth2ControlAddIn(AuthRequestUrl: Text; State: Text; var AuthCode: Text; var AuthCodeErr: Text)
    var
        VATGroupAccessDialog: Page "VAT Group Access Dialog";
    begin
        if AuthRequestUrl = '' then begin
            AuthCode := '';
            exit;
        end;

        VATGroupAccessDialog.SetOAuth2Properties(AuthRequestUrl, State);
        VATGroupAccessDialog.RunModal();

        AuthCode := VATGroupAccessDialog.GetAuthCode();
        AuthCodeErr := VATGroupAccessDialog.GetAuthError();
    end;

    internal procedure PrepareURI(Endpoint: Text) Result: Text
    begin
        CheckLoadVATReportSetup();
        Result := VATReportSetup."Group Representative API URL";
        CASE VATReportSetup."VAT Group BC Version" OF
            VATReportSetup."VAT Group BC Version"::BC:
                Result += StrSubstNo(URLAppendixCompanyLbl, VATReportSetup."Group Representative Company");
            VATReportSetup."VAT Group BC Version"::NAV2018:
                Result += StrSubstNo(URLAppendixCompany2018Lbl, VATReportSetup."Group Representative Company");
            VATReportSetup."VAT Group BC Version"::NAV2017:
                Result += StrSubstNo(URLAppendixCompany2017Lbl, VATReportSetup."Group Representative Company");
        END;
        Result += Endpoint;
    end;

    internal procedure GetVATGroupSubmissionStatusEndpoint(): Text
    begin
        CheckLoadVATReportSetup();
        case VATReportSetup."VAT Group BC Version" of
            VATReportSetup."VAT Group BC Version"::BC,
            VATReportSetup."VAT Group BC Version"::NAV2018:
                exit(VATGroupSubmissionStatusEndpointTxt);
            VATReportSetup."VAT Group BC Version"::NAV2017:
                exit(VATGroupSubmissionStatusEndpoint2017Txt);
        end;
    end;

    local procedure PrepareBatchURI(Endpoint: Text) Result: Text
    begin
        Result := VATReportSetup."Group Representative API URL";
        case VATReportSetup."VAT Group BC Version" of
            VATReportSetup."VAT Group BC Version"::BC:
                Result += URLAppendixLbl;
            VATReportSetup."VAT Group BC Version"::NAV2018:
                Result += URLAppendix2018Lbl;
            VATReportSetup."VAT Group BC Version"::NAV2017:
                Result += URLAppendix2017Lbl;
        end;
        Result += Endpoint;
    end;

    local procedure CheckLoadVATReportSetup()
    begin
        if not VATReportSetupIsLoaded then begin
            if not VATReportSetup.Get() then
                Error(NoVATSetupErr);
            VATReportSetupIsLoaded := true;
        end;
    end;
}