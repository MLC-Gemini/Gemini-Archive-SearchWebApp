#pragma checksum "C:\Temp\VisualStudio Source\GemArchSearchWebApp\GeminiSearchWebApp\Views\Home\SearchCases.cshtml" "{ff1816ec-aa5e-4d10-87f7-6f4963833460}" "748eba8297f9eca16bb505e15c113b844f1d9a95"
// <auto-generated/>
#pragma warning disable 1591
[assembly: global::Microsoft.AspNetCore.Razor.Hosting.RazorCompiledItemAttribute(typeof(AspNetCore.Views_Home_SearchCases), @"mvc.1.0.view", @"/Views/Home/SearchCases.cshtml")]
namespace AspNetCore
{
    #line hidden
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Threading.Tasks;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.AspNetCore.Mvc.Rendering;
    using Microsoft.AspNetCore.Mvc.ViewFeatures;
#nullable restore
#line 1 "C:\Temp\VisualStudio Source\GemArchSearchWebApp\GeminiSearchWebApp\Views\_ViewImports.cshtml"
using GeminiSearchWebApp;

#line default
#line hidden
#nullable disable
#nullable restore
#line 2 "C:\Temp\VisualStudio Source\GemArchSearchWebApp\GeminiSearchWebApp\Views\_ViewImports.cshtml"
using GeminiSearchWebApp.Models;

#line default
#line hidden
#nullable disable
#nullable restore
#line 1 "C:\Temp\VisualStudio Source\GemArchSearchWebApp\GeminiSearchWebApp\Views\Home\SearchCases.cshtml"
using System.Data;

#line default
#line hidden
#nullable disable
    [global::Microsoft.AspNetCore.Razor.Hosting.RazorSourceChecksumAttribute(@"SHA1", @"748eba8297f9eca16bb505e15c113b844f1d9a95", @"/Views/Home/SearchCases.cshtml")]
    [global::Microsoft.AspNetCore.Razor.Hosting.RazorSourceChecksumAttribute(@"SHA1", @"0890da2bea6a613c6fe5116e779293221719f1ee", @"/Views/_ViewImports.cshtml")]
    public class Views_Home_SearchCases : global::Microsoft.AspNetCore.Mvc.Razor.RazorPage<dynamic>
    {
        private static readonly global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute __tagHelperAttribute_0 = new global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute("value", "", global::Microsoft.AspNetCore.Razor.TagHelpers.HtmlAttributeValueStyle.DoubleQuotes);
        private static readonly global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute __tagHelperAttribute_1 = new global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute("style", new global::Microsoft.AspNetCore.Html.HtmlString("display:none; text-align:center;"), global::Microsoft.AspNetCore.Razor.TagHelpers.HtmlAttributeValueStyle.DoubleQuotes);
        private static readonly global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute __tagHelperAttribute_2 = new global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute("value", "Account Level", global::Microsoft.AspNetCore.Razor.TagHelpers.HtmlAttributeValueStyle.DoubleQuotes);
        private static readonly global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute __tagHelperAttribute_3 = new global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute("value", "Adviser Level", global::Microsoft.AspNetCore.Razor.TagHelpers.HtmlAttributeValueStyle.DoubleQuotes);
        private static readonly global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute __tagHelperAttribute_4 = new global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute("value", "Customer Level", global::Microsoft.AspNetCore.Razor.TagHelpers.HtmlAttributeValueStyle.DoubleQuotes);
        #line hidden
        #pragma warning disable 0649
        private global::Microsoft.AspNetCore.Razor.Runtime.TagHelpers.TagHelperExecutionContext __tagHelperExecutionContext;
        #pragma warning restore 0649
        private global::Microsoft.AspNetCore.Razor.Runtime.TagHelpers.TagHelperRunner __tagHelperRunner = new global::Microsoft.AspNetCore.Razor.Runtime.TagHelpers.TagHelperRunner();
        #pragma warning disable 0169
        private string __tagHelperStringValueBuffer;
        #pragma warning restore 0169
        private global::Microsoft.AspNetCore.Razor.Runtime.TagHelpers.TagHelperScopeManager __backed__tagHelperScopeManager = null;
        private global::Microsoft.AspNetCore.Razor.Runtime.TagHelpers.TagHelperScopeManager __tagHelperScopeManager
        {
            get
            {
                if (__backed__tagHelperScopeManager == null)
                {
                    __backed__tagHelperScopeManager = new global::Microsoft.AspNetCore.Razor.Runtime.TagHelpers.TagHelperScopeManager(StartTagHelperWritingScope, EndTagHelperWritingScope);
                }
                return __backed__tagHelperScopeManager;
            }
        }
        private global::Microsoft.AspNetCore.Mvc.Razor.TagHelpers.HeadTagHelper __Microsoft_AspNetCore_Mvc_Razor_TagHelpers_HeadTagHelper;
        private global::Microsoft.AspNetCore.Mvc.Razor.TagHelpers.BodyTagHelper __Microsoft_AspNetCore_Mvc_Razor_TagHelpers_BodyTagHelper;
        private global::Microsoft.AspNetCore.Mvc.TagHelpers.OptionTagHelper __Microsoft_AspNetCore_Mvc_TagHelpers_OptionTagHelper;
        #pragma warning disable 1998
        public async override global::System.Threading.Tasks.Task ExecuteAsync()
        {
            WriteLiteral(" \r\n");
#nullable restore
#line 4 "C:\Temp\VisualStudio Source\GemArchSearchWebApp\GeminiSearchWebApp\Views\Home\SearchCases.cshtml"
  

    ViewBag.title = "Search Cases";


#line default
#line hidden
#nullable disable
            __tagHelperExecutionContext = __tagHelperScopeManager.Begin("head", global::Microsoft.AspNetCore.Razor.TagHelpers.TagMode.StartTagAndEndTag, "748eba8297f9eca16bb505e15c113b844f1d9a955418", async() => {
                WriteLiteral("\r\n    <title>Gemini Case Search</title>\r\n\r\n\r\n    <script src=\"https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.js\" type=\"text/javascript\"></script>\r\n");
                WriteLiteral("    <link href=\"https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/themes/ui-lightness/jquery-ui.css\" rel=\"stylesheet\" />\r\n    <script type=\"text/javascript\" src=\"https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/jquery-ui.min.js\"></script>\r\n\r\n");
                WriteLiteral(@"
  

    <script src=""https://cdn.datatables.net/1.10.25/js/jquery.dataTables.min.js"" defer></script>
    <link href=""https://cdn.datatables.net/1.10.22/css/jquery.dataTables.min.css"" rel=""stylesheet"" />


    <script type=""text/javascript"">

        $(document).ready(function () {
            //$(""#myForm"").on(""change"", ""#eventType"", function (event) {
            //    event.delegateTarget.reset();
            //});
            //$.fn.resetForm = function () {
            //    if ($(""#filter_level"").change() || $(""#Pid"").change() || $(""#dateRange"").change() || $(""#toRange"").change() || $(""#rdbCaseCreationDate"").change()) {
            //        if (!$(""caseContainer"").empty()) {
            //            $(""#myForm"").reset();
            //        }
            //    }

            //};
            $.fn.resetForm = function () {
                $(""input"").change(function () {
                    if ($.fn.ifEmpty() == false) {
                        location.reload();
             ");
                WriteLiteral(@"       }
                })
                $(""#filter_level"").change(function () {
                    if ($.fn.ifEmpty() == false) {
                        location.reload();
                    }
                })
                //$(""#dateRange"").change(function () {
                //    if ($.fn.ifEmpty() == false) {
                //        location.reload();
                //    }
                //})
                //$(""#toRange"").change(function () {
                //    if ($.fn.ifEmpty() == false) {
                //        location.reload();
                //    }
                //})
            };
            var empty = false;
            $.fn.ifEmpty = function () {
                $('input[type=""text""]').each(function () {
                    console.log($(this).val());
                    if ($(this).val() == """") {
                        empty = true;
                        return true;
                    }
                })
                return fals");
                WriteLiteral(@"e;
            };
            
            console.log($.fn.ifEmpty());
            $(""#btnSearch"").click(function () {
                var from = $(""#dateRange"").val();
                var to = $(""#toRange"").val();
                var d = new Date(from.split(""/"").reverse().join(""-""));
                var dd = d.getDate();
                var mm = d.getMonth() + 1;
                var yy = d.getFullYear();
                var startDate = mm + ""/"" + dd + ""/"" + yy;
                var d = new Date(to.split(""/"").reverse().join(""-""));
                var ddt = d.getDate();
                var mmt = d.getMonth() + 1;
                var yyt = d.getFullYear();
                var endDate = mmt + ""/"" + ddt + ""/"" + yyt;

                if (!$('#filter_level').val() && document.getElementById(""Pid"").value.length == 0) {

                    alert('");
#nullable restore
#line 94 "C:\Temp\VisualStudio Source\GemArchSearchWebApp\GeminiSearchWebApp\Views\Home\SearchCases.cshtml"
                      Write(ViewBag.emptySearch);

#line default
#line hidden
#nullable disable
                WriteLiteral("\');\r\n                }\r\n                else if (!$(\'#filter_level\').val()) {\r\n                    alert(\'");
#nullable restore
#line 97 "C:\Temp\VisualStudio Source\GemArchSearchWebApp\GeminiSearchWebApp\Views\Home\SearchCases.cshtml"
                      Write(ViewBag.emptySearchLevel);

#line default
#line hidden
#nullable disable
                WriteLiteral("\');\r\n                }\r\n                else if ($(\'#filter_level\').val() == \"Account Level\" && document.getElementById(\"Pid\").value.length == 0) {\r\n                    alert(\'");
#nullable restore
#line 100 "C:\Temp\VisualStudio Source\GemArchSearchWebApp\GeminiSearchWebApp\Views\Home\SearchCases.cshtml"
                      Write(ViewBag.emptyAccountID);

#line default
#line hidden
#nullable disable
                WriteLiteral("\')\r\n                }\r\n                else if ($(\'#filter_level\').val() == \"Adviser Level\" && document.getElementById(\"Pid\").value.length == 0) {\r\n                    alert(\'");
#nullable restore
#line 103 "C:\Temp\VisualStudio Source\GemArchSearchWebApp\GeminiSearchWebApp\Views\Home\SearchCases.cshtml"
                      Write(ViewBag.emptyAdviserID);

#line default
#line hidden
#nullable disable
                WriteLiteral("\')\r\n                }\r\n                else if ($(\'#filter_level\').val() == \"Customer Level\" && document.getElementById(\"Pid\").value.length == 0) {\r\n                    alert(\'");
#nullable restore
#line 106 "C:\Temp\VisualStudio Source\GemArchSearchWebApp\GeminiSearchWebApp\Views\Home\SearchCases.cshtml"
                      Write(ViewBag.emptyCustomerID);

#line default
#line hidden
#nullable disable
                WriteLiteral("\')\r\n                }\r\n                else if (document.getElementById(\"Pid\").value.length == 0) {\r\n                    alert(\'");
#nullable restore
#line 109 "C:\Temp\VisualStudio Source\GemArchSearchWebApp\GeminiSearchWebApp\Views\Home\SearchCases.cshtml"
                      Write(ViewBag.emptySearchPid);

#line default
#line hidden
#nullable disable
                WriteLiteral("\');\r\n                }\r\n                else if ((Date.parse(startDate)) >= (Date.parse(endDate))) {\r\n                    alert(\'");
#nullable restore
#line 112 "C:\Temp\VisualStudio Source\GemArchSearchWebApp\GeminiSearchWebApp\Views\Home\SearchCases.cshtml"
                      Write(ViewBag.fromDateGreaterThanToDate);

#line default
#line hidden
#nullable disable
                WriteLiteral("\');\r\n                }\r\n                else if ($(\'input[name=\"date_case\"]:checked\').length == 0) {\r\n                    alert(\'");
#nullable restore
#line 115 "C:\Temp\VisualStudio Source\GemArchSearchWebApp\GeminiSearchWebApp\Views\Home\SearchCases.cshtml"
                      Write(ViewBag.emptyCaseTypeDate);

#line default
#line hidden
#nullable disable
                WriteLiteral(@"');
                }
                else {
                    alert(""Filter Level:"" + $(""#filter_level option:selected"").val() + ""\r\nID:"" + $(""#Pid"").val() + ""\r\nFrom Date:"" + $(""input[id='dateRange']"").val() + ""\r\nTo Date:"" + $(""input[id='toRange']"").val() + ""\r\nCase Date:"" + $('input[name=""date_case""]:checked').val());
                    //$(""#myTable"").show();
                    //$(""#docTable"").show();
                    $(""#output1"").show();
                    $(""#output2"").show();
                }

                
                var aFilterValue = $(""#filter_level option:selected"").val();
                var aIdValue = $(""#Pid"").val();
                var aFromDate = $(""#dateRange"").val();
                var aToDate = $(""#toRange"").val();
                var aCaseType = $('input[name=""date_case""]:checked').val();
                $.ajax(
                    {
                        type: ""POST"",
                        url: ""/Home/GetSearchCases"",
                     ");
                WriteLiteral(@"   dataType: ""JSON"",
                        data: { filterLevel: aFilterValue, userId: aIdValue, fromDate: aFromDate, toDate: aToDate, caseDateType: aCaseType },
                        success: function (result) {
                            console.log(""success"");
                            console.log(result);
                            console.log($.fn.ifEmpty());
                            console.log(aFilterValue + aIdValue + aCaseType + aFromDate + aToDate);
                            var rows = """";
                            var rowsDoc = """";
                            $.each(result, function (i, item) {
                                    rows = ""<tr>""
                                    + ""<td >"" + item.Account + ""</td>""
                                    + ""<td >"" + item.Status + ""</td>""
                                    + ""<td >"" + item.CaseType + ""</td>""
                                    + ""<td >"" + item.Created + ""</td>""
                                    + ""<td >"" + ");
                WriteLiteral(@"item.Completed + ""</td>""
                                    + ""<td >"" + item.Priority + ""</td>""
                                    + ""<td >"" + item.Adviser + ""</td>""
                                    + ""<td >"" + item.Flag + ""</td>""
                                    + ""<td >"" + item.CustomerId + ""</td>""
                                    + ""<td >"" + item.Requestor + ""</td>""
                                    + ""<td >"" + item.CaseID + ""</td>""
                                    + ""<td >"" + item.WorkpackID + ""</td>""
                                    + ""<td >"" + item.Team + ""</td>""
                                    + ""<td >"" + item.InPFC + ""</td>""
                                    + ""<td >"" + item.Employee + ""</td>""
                                    + ""</tr>"";
                                $('#caseContainer').append(rows);
                                $('.odd').hide();

                            });


                            $.each(result, function (i, item) {
       ");
                WriteLiteral(@"                         rowsDoc = ""<tr>""
                                    + ""<td >"" + item.DocumentType + ""</td>""
                                    + ""<td >"" + item.Created + ""</td>""
                                    + ""<td >"" + item.Id + ""</td>""
                                    + ""<td >"" + item.Source + ""</td>""
                                    + ""<td >"" + item.BoxID + ""</td>""
                                    + ""<td >"" + item.BundleID + ""</td>""
                                    + ""<td >"" + item.DateTimeReceived + ""</td>""
                                    + ""<td >"" + item.LetterDescription + ""</td>""                                    
                                    + ""</tr>"";
                                $('#docContainer').append(rowsDoc);

                            });


                        },
                        error: function () {
                            console.log(""Error"");
                        }

                    });

               ");
                WriteLiteral(@" $.fn.resetForm();

            });

            $(""#myTable"").dataTable({
                pageLength: 10,
                searching: false,
                scrollX:true,
                scrollY: true,
                scrollCollapse: true,
                fixedColumns: {
                    heightMatch: 'none',
                },
                lengthMenu: [[10, 20, 50, -1], [10, 20, 50, 'All records']]
            });
            $(""#docTable"").dataTable({
                pageLength: 10,
                searching: false,
                scrollX: true,
                scrollY: true,
                fixedColumns: {
                    heightMatch: 'none',
                },
                lengthMenu: [[10, 20, 50, -1], [10, 20, 50, 'All records']]
            });
            $(""#actionTable"").dataTable({
                pageLength: 10,
                searching: false,
                lengthMenu: [[10, 20, 50, -1], [10, 20, 50, 'All records']]
            });
        });
    </");
                WriteLiteral(@"script>

    <style>
        table {
            white-space: nowrap;
            width: 550px;
            background-color: aliceblue;
            font-size: 17px;
            font-family: 'Times New Roman';
            font-style: normal;
            text-align: center;
            max-height: 10px;
        }
        .rowHighlighter tr:hover td {
            background-color: lightblue;
        }
        th,td{
            white-space:nowrap;
        }
        div.dataTables_wrapper {
            width: 100%;
            margin: 0 auto;
        }
        #btnSearch {
            padding: 0px 20px 0px 20px;
            font-size: 16px;
            font-weight:bold;
            margin: 10px 10px 10px 10px;
        }
            #btnSearch:hover{
                background-color:lightskyblue;
            }
        .datepicker {
            width: 130px;
            margin: 20px 0px 10px 0px
        }

        .textBoxInput {
            width: 100px;
            outline:");
                WriteLiteral(@" double;
        }

        .labelStyle {
            padding-left: 10px;
            font-weight: bold;
            font-style: normal;
            text-align: left;
        }

        .modal {
            display: none;
            position: fixed;
            z-index: 1;
            padding-top: 100px;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgb(0,0,0);
            background-color: rgba(0,0,0,0.4);
        }

        .modal-content {
            width: auto;
            margin: auto;
            padding: 20px;
            border: 1px solid #888;
            width: 80%;
        }

        .close {
            color: #aaaaaa;
            float: right;
            font-size: 28px;
            font-weight: bold;
        }

            .close:hover,
            .close:focus {
                color: #000;
                text-decoration: none;
                c");
                WriteLiteral("ursor: pointer;\r\n            }\r\n    </style>\r\n");
            }
            );
            __Microsoft_AspNetCore_Mvc_Razor_TagHelpers_HeadTagHelper = CreateTagHelper<global::Microsoft.AspNetCore.Mvc.Razor.TagHelpers.HeadTagHelper>();
            __tagHelperExecutionContext.Add(__Microsoft_AspNetCore_Mvc_Razor_TagHelpers_HeadTagHelper);
            await __tagHelperRunner.RunAsync(__tagHelperExecutionContext);
            if (!__tagHelperExecutionContext.Output.IsContentModified)
            {
                await __tagHelperExecutionContext.SetOutputContentAsync();
            }
            Write(__tagHelperExecutionContext.Output);
            __tagHelperExecutionContext = __tagHelperScopeManager.End();
            WriteLiteral("\r\n\r\n");
            __tagHelperExecutionContext = __tagHelperScopeManager.Begin("body", global::Microsoft.AspNetCore.Razor.TagHelpers.TagMode.StartTagAndEndTag, "748eba8297f9eca16bb505e15c113b844f1d9a9520835", async() => {
                WriteLiteral(@"
    <div>
        <table style=""border: 1px solid black; border-style: double; border-color:black; border-width:thick"">
            <tr>
                <td>
                    <table>
                        <tr>
                            <td colspan=""1"" align=""center"">
                                <label for=""filter_level"" class=""labelStyle"">Search By: </label>
                                <select name=""filter_level"" id=""filter_level"" style=""width:150px; height:30px;"">
                                    ");
                __tagHelperExecutionContext = __tagHelperScopeManager.Begin("option", global::Microsoft.AspNetCore.Razor.TagHelpers.TagMode.StartTagAndEndTag, "748eba8297f9eca16bb505e15c113b844f1d9a9521639", async() => {
                    WriteLiteral("--Select--");
                }
                );
                __Microsoft_AspNetCore_Mvc_TagHelpers_OptionTagHelper = CreateTagHelper<global::Microsoft.AspNetCore.Mvc.TagHelpers.OptionTagHelper>();
                __tagHelperExecutionContext.Add(__Microsoft_AspNetCore_Mvc_TagHelpers_OptionTagHelper);
                __Microsoft_AspNetCore_Mvc_TagHelpers_OptionTagHelper.Value = (string)__tagHelperAttribute_0.Value;
                __tagHelperExecutionContext.AddTagHelperAttribute(__tagHelperAttribute_0);
                __tagHelperExecutionContext.AddHtmlAttribute(__tagHelperAttribute_1);
                await __tagHelperRunner.RunAsync(__tagHelperExecutionContext);
                if (!__tagHelperExecutionContext.Output.IsContentModified)
                {
                    await __tagHelperExecutionContext.SetOutputContentAsync();
                }
                Write(__tagHelperExecutionContext.Output);
                __tagHelperExecutionContext = __tagHelperScopeManager.End();
                WriteLiteral("\r\n                                    ");
                __tagHelperExecutionContext = __tagHelperScopeManager.Begin("option", global::Microsoft.AspNetCore.Razor.TagHelpers.TagMode.StartTagAndEndTag, "748eba8297f9eca16bb505e15c113b844f1d9a9522990", async() => {
                    WriteLiteral("Account Level");
                }
                );
                __Microsoft_AspNetCore_Mvc_TagHelpers_OptionTagHelper = CreateTagHelper<global::Microsoft.AspNetCore.Mvc.TagHelpers.OptionTagHelper>();
                __tagHelperExecutionContext.Add(__Microsoft_AspNetCore_Mvc_TagHelpers_OptionTagHelper);
                __Microsoft_AspNetCore_Mvc_TagHelpers_OptionTagHelper.Value = (string)__tagHelperAttribute_2.Value;
                __tagHelperExecutionContext.AddTagHelperAttribute(__tagHelperAttribute_2);
                await __tagHelperRunner.RunAsync(__tagHelperExecutionContext);
                if (!__tagHelperExecutionContext.Output.IsContentModified)
                {
                    await __tagHelperExecutionContext.SetOutputContentAsync();
                }
                Write(__tagHelperExecutionContext.Output);
                __tagHelperExecutionContext = __tagHelperScopeManager.End();
                WriteLiteral("\r\n                                    ");
                __tagHelperExecutionContext = __tagHelperScopeManager.Begin("option", global::Microsoft.AspNetCore.Razor.TagHelpers.TagMode.StartTagAndEndTag, "748eba8297f9eca16bb505e15c113b844f1d9a9524257", async() => {
                    WriteLiteral("Adviser Level");
                }
                );
                __Microsoft_AspNetCore_Mvc_TagHelpers_OptionTagHelper = CreateTagHelper<global::Microsoft.AspNetCore.Mvc.TagHelpers.OptionTagHelper>();
                __tagHelperExecutionContext.Add(__Microsoft_AspNetCore_Mvc_TagHelpers_OptionTagHelper);
                __Microsoft_AspNetCore_Mvc_TagHelpers_OptionTagHelper.Value = (string)__tagHelperAttribute_3.Value;
                __tagHelperExecutionContext.AddTagHelperAttribute(__tagHelperAttribute_3);
                await __tagHelperRunner.RunAsync(__tagHelperExecutionContext);
                if (!__tagHelperExecutionContext.Output.IsContentModified)
                {
                    await __tagHelperExecutionContext.SetOutputContentAsync();
                }
                Write(__tagHelperExecutionContext.Output);
                __tagHelperExecutionContext = __tagHelperScopeManager.End();
                WriteLiteral("\r\n                                    ");
                __tagHelperExecutionContext = __tagHelperScopeManager.Begin("option", global::Microsoft.AspNetCore.Razor.TagHelpers.TagMode.StartTagAndEndTag, "748eba8297f9eca16bb505e15c113b844f1d9a9525524", async() => {
                    WriteLiteral("Customer Level");
                }
                );
                __Microsoft_AspNetCore_Mvc_TagHelpers_OptionTagHelper = CreateTagHelper<global::Microsoft.AspNetCore.Mvc.TagHelpers.OptionTagHelper>();
                __tagHelperExecutionContext.Add(__Microsoft_AspNetCore_Mvc_TagHelpers_OptionTagHelper);
                __Microsoft_AspNetCore_Mvc_TagHelpers_OptionTagHelper.Value = (string)__tagHelperAttribute_4.Value;
                __tagHelperExecutionContext.AddTagHelperAttribute(__tagHelperAttribute_4);
                await __tagHelperRunner.RunAsync(__tagHelperExecutionContext);
                if (!__tagHelperExecutionContext.Output.IsContentModified)
                {
                    await __tagHelperExecutionContext.SetOutputContentAsync();
                }
                Write(__tagHelperExecutionContext.Output);
                __tagHelperExecutionContext = __tagHelperScopeManager.End();
                WriteLiteral(@"
                                </select>
                            </td>
                            <td colspan=""1"" align=""left"">
                                <input id=""Pid"" type=""text"" class=""textBoxInput"" size=""10"" placeholder=""Enter ID"" style=""text-align:center;"" />
                            </td>
                        </tr>
                    </table>
                </td>
                <td>
                    <table>
                        <tr>
                            <td>
                                <label for=""dateRange"" class=""labelStyle"">From Date:</label>
");
                WriteLiteral(@"
                                <input type=""text"" id=""dateRange"" class=""datepicker"" title=""From"" style=""outline:double"" readonly />

                                <script>
                                    $("".datepicker"").datepicker({
                                        dateFormat: 'dd/mm/yy',
                                        changeMonth: true,
                                        changeYear: true,
                                        yearRange: ""1980:+nn"",
                                        onSelect: function (dateText) {
                                            console.log(""selected Date:"" + dateText + "";inputs's current value:"" + this.value);
                                            $(this).change();
                                        }
                                    });
                                </script>
                            <td />
                            <td>
                                <label for=""toRange"" class=""labelSt");
                WriteLiteral(@"yle"">To Date:</label>
                                <input type=""text"" id=""toRange"" class=""datepicker"" title=""To"" style=""outline:double"" readonly>

                                <script>
                                    $("".datepicker"").datepicker({
                                        dateFormat: 'dd/mm/yy',
                                        changeMonth: true,
                                        changeYear: true,
                                        yearRange: ""1980:+nn"",
                                        onSelect: function (dateText) {
                                            console.log(""selected Date:"" + dateText + "";inputs's current value:"" + this.value);
                                            $(this).change();
                                        }
                                    });
                                </script>
                            </td>
                        </tr>
                        <tr>
                          ");
                WriteLiteral(@"  <td align=""left"">
                                <input id=""rdbCaseCreationDate"" type=""radio"" name=""date_case"" value=""Case Creation Date"" checked=""checked"" />
                                <label for=""rdbCaseCreationDate"" class=""labelStyle"">Case Creation Date</label>
                            </td>
                        </tr>
                        <tr>
                            <td align=""left"">
                                <input id=""rdbCaseClosedDate"" type=""radio"" name=""date_case"" value=""CaseClosed Date"" />
                                <label for=""rdbCaseClosedDate"" class=""labelStyle"">Case Closed Date</label>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr align=""center"">
                <td colspan=""2"" style=""vertical-align:top;"">
                    <button id=""btnSearch"" type=""button"" name=""btn_search"" value=""search"" >Search</button>
                </td>
            <");
                WriteLiteral(@"/tr>
        </table>
    </div>
    <div id=""output1"" style=""display: none;"">
        <label for=""caseText"" class=""labelStyle"">Cases:</label>
        <div style="" border: 3px ridge black; "" ng-controller=""HomeController"">
            <table id=""myTable"" class=""table table-condensed rowHighlighter"" style=""width:contain;  border: 1px ridge lightgray; margin: 0px 10px 0px 10px; background-color:lightskyblue;"">
                <thead>
                    <tr style=""vertical-align:top"">
                        <th>Account</th>
                        <th>Status</th>
                        <th>Case Type</th>
                        <th>Created</th>
                        <th>Completed</th>
                        <th>Priority</th>
                        <th>Adviser</th>
                        <th>Flag</th>
                        <th>Customer Id</th>
                        <th>Requestor</th>
                        <th>Case ID</th>
                        <th>Workpack ID</th>
            ");
                WriteLiteral(@"            <th>Team</th>
                        <th>InPFC</th>
                        <th>Employee</th>
                    </tr>
                </thead>
                <tbody id=""caseContainer"">
                </tbody>
            </table>
        </div>
    </div>
    <div id=""output2"" style="" display:none"">
        <label for=""documentText"" class=""labelStyle"">Documents:</label>
        <div style=""border: 3px ridge black; "">
            <table id=""docTable"" class=""table table-condensed"" style=""width: contain; border: 1px ridge lightgray; margin: 0px 10px 0px 10px; background-color: lightskyblue; "">
                <thead>
                    <tr style=""vertical-align:top"">
                        <th>Document Type</th>
                        <th>Created</th>
                        <th>Id</th>
                        <th>Source</th>
                        <th>Box/Batch</th>
                        <th>Bundle Id</th>
                        <th>Date/Time Received</th>
        ");
                WriteLiteral(@"                <th>Id - Letter Description</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody id=""docContainer"" class=""rowHighlighter"">
                </tbody>
            </table>
        </div>
    </div>

    <div id=""caseModal"" class=""modal"" title=""Case Activities"">
        <div class=""modal-content"">
            <span class=""close"">&times;</span>
            <div style=""overflow:scroll"">
                <table id=""actionTable"" class=""table table-condensed"" style=""border: 1px ridge lightgray"">
                    <thead>
                        <tr>
                            <th>Action</th>
                            <th>Date and Time</th>
                            <th>Employee</th>
                            <th>Message</th>
                        </tr>
                    </thead>
                    <tbody id=""actionContainer"" class=""rowHighliter"">
                        <tr>
                            <td");
                WriteLiteral(@">Case Created</td>
                            <td>24 Apr 2002</td>
                            <td>ABCD</td>
                            <td>Case created by ABCD</td>
                        </tr>
                        <tr>
                            <td>Case Message</td>
                            <td>29 Apr 2002</td>
                            <td>ABCD</td>
                            <td>Product is ready for use</td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <br />
            <br />
            <div>
                <label for=""fullTextMessage"" class=""labelStyle"">Full Text of Message:</label><br />
                <textarea id=""fullTextMessage"" rows=""5"" cols=""150"" readonly style=""outline:double; max-width:100%; resize:none""></textarea>
            </div>
        </div>
    </div>
    <script>
        var caseRow = document.getElementById(""myTable"")
        var modal = document.getElementById(""caseModal"")");
                WriteLiteral(@"
        var span = document.getElementsByClassName(""close"")[0];

        document.oncontextmenu = function () { return false; };

        $(caseRow).mousedown(function (e) {
            if (e.button == 2) {
                modal.style.display = ""block"";
                return false;
            }
        });

        // When the user clicks on <span> (x), close the modal
        span.onclick = function () {
            modal.style.display = ""none"";
        }

        // When the user clicks anywhere outside of the modal, close it
        window.onclick = function (event) {
            if (event.target == modal) {
                modal.style.display = ""none"";
            }
        }

        $(""#actionContainer tr"").click(function () {
            var $row = $(this).closest(""tr""),
                $tds = $row.find(""td:nth-child(4)"");
            $(""#fullTextMessage"").text('').append($tds.text());
        });
    </script>


");
            }
            );
            __Microsoft_AspNetCore_Mvc_Razor_TagHelpers_BodyTagHelper = CreateTagHelper<global::Microsoft.AspNetCore.Mvc.Razor.TagHelpers.BodyTagHelper>();
            __tagHelperExecutionContext.Add(__Microsoft_AspNetCore_Mvc_Razor_TagHelpers_BodyTagHelper);
            await __tagHelperRunner.RunAsync(__tagHelperExecutionContext);
            if (!__tagHelperExecutionContext.Output.IsContentModified)
            {
                await __tagHelperExecutionContext.SetOutputContentAsync();
            }
            Write(__tagHelperExecutionContext.Output);
            __tagHelperExecutionContext = __tagHelperScopeManager.End();
            WriteLiteral("\r\n\r\n\r\n");
        }
        #pragma warning restore 1998
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.ViewFeatures.IModelExpressionProvider ModelExpressionProvider { get; private set; }
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.IUrlHelper Url { get; private set; }
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.IViewComponentHelper Component { get; private set; }
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.Rendering.IJsonHelper Json { get; private set; }
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.Rendering.IHtmlHelper<dynamic> Html { get; private set; }
    }
}
#pragma warning restore 1591