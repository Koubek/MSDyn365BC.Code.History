table 14919 "Excel Template"
{
    Caption = 'Excel Template';
    LookupPageID = "Excel Templates";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(3; "File Name"; Text[250])
        {
            Caption = 'File Name';
        }
        field(4; BLOB; BLOB)
        {
            Caption = 'BLOB';
        }
        field(5; "File Extension"; Option)
        {
            Caption = 'File Extension';
            OptionCaption = 'XLS,XLSX';
            OptionMembers = XLS,XLSX;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        Text001: Label 'You should import template file for template code %1.';
        FileMgt: Codeunit "File Management";

    [Scope('OnPrem')]
    procedure OpenTemplate(TemplateCode: Code[10]) FileName: Text[1024]
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        Get(TemplateCode);
        CalcFields(BLOB);
        if not BLOB.HasValue then
            Error(Text001, TemplateCode);

        if "File Name" <> '' then begin
            FileName := CopyStr(FileMgt.ServerTempFileName(''), 1, 1024);
            if Exists(FileName) then
                Erase(FileName);
            TempBlob.FromRecord(Rec, FieldNo(BLOB));
            FileMgt.BLOBExportToServerFile(TempBlob, FileName);
        end;
    end;

    [Scope('OnPrem')]
    procedure GetTemplateFileName(TemplateCode: Code[10]): Text
    begin
        Get(TemplateCode);
        exit("File Name");
    end;

    local procedure LoadSheetSectionHeights(ServerFileName: Text; SheetName: Text)
    var
        ExcelTemplateSection: Record "Excel Template Section";
        ReportBuilder: DotNet ReportBuilder;
        SectionInfo: DotNet HeightInfo;
        List: DotNet IList;
        I: Integer;
    begin
        List := ReportBuilder.GetReportSectionHeights(ServerFileName, SheetName);
        for I := 0 to List.Count - 1 do begin
            SectionInfo := List.Item(I);
            ExcelTemplateSection.Init;
            ExcelTemplateSection."Template Code" := Code;
            ExcelTemplateSection."Sheet Name" := SheetName;
            ExcelTemplateSection.Name := SectionInfo.Name;
            ExcelTemplateSection.Height := SectionInfo.Height;
            ExcelTemplateSection.Insert;
        end;
    end;

    [Scope('OnPrem')]
    procedure UpdateTemplateHeight(FileName: Text)
    var
        ExcelTemplateSheet: Record "Excel Template Sheet";
        ExcelTemplateSection: Record "Excel Template Section";
        ReportBuilder: DotNet ReportBuilder;
        SheetInfo: DotNet HeightInfo;
        List: DotNet IList;
        I: Integer;
        ServerFileName: Text;
    begin
        if LowerCase(FileMgt.GetExtension(FileName)) <> 'xlsx' then
            exit;

        ExcelTemplateSheet.SetRange("Template Code", Code);
        ExcelTemplateSheet.DeleteAll;
        ExcelTemplateSection.SetRange("Template Code", Code);
        ExcelTemplateSection.DeleteAll;
        Commit;

        ServerFileName := FileMgt.UploadFileToServer(FileName);
        List := ReportBuilder.GetReportSheetsPrintZoneHeight(ServerFileName);
        for I := 0 to List.Count - 1 do begin
            SheetInfo := List.Item(I);
            ExcelTemplateSheet.Init;
            ExcelTemplateSheet."Template Code" := Code;
            ExcelTemplateSheet.Name := SheetInfo.Name;
            ExcelTemplateSheet."Paper Height" := SheetInfo.Height;
            ExcelTemplateSheet.Insert;

            LoadSheetSectionHeights(ServerFileName, SheetInfo.Name);
        end;
    end;
}
