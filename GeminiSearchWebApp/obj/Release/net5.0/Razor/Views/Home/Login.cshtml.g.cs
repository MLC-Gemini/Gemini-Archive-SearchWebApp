#pragma checksum "C:\Temp\VisualStudio Source\GeminiProjectMaster\Gemini-Archive-SearchWebApp\GeminiSearchWebApp\Views\Home\Login.cshtml" "{ff1816ec-aa5e-4d10-87f7-6f4963833460}" "bdf9de882082d6dd75654b636348ce75cc2a7a28"
// <auto-generated/>
#pragma warning disable 1591
[assembly: global::Microsoft.AspNetCore.Razor.Hosting.RazorCompiledItemAttribute(typeof(AspNetCore.Views_Home_Login), @"mvc.1.0.view", @"/Views/Home/Login.cshtml")]
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
#line 1 "C:\Temp\VisualStudio Source\GeminiProjectMaster\Gemini-Archive-SearchWebApp\GeminiSearchWebApp\Views\_ViewImports.cshtml"
using GeminiSearchWebApp;

#line default
#line hidden
#nullable disable
#nullable restore
#line 2 "C:\Temp\VisualStudio Source\GeminiProjectMaster\Gemini-Archive-SearchWebApp\GeminiSearchWebApp\Views\_ViewImports.cshtml"
using GeminiSearchWebApp.Models;

#line default
#line hidden
#nullable disable
    [global::Microsoft.AspNetCore.Razor.Hosting.RazorSourceChecksumAttribute(@"SHA1", @"bdf9de882082d6dd75654b636348ce75cc2a7a28", @"/Views/Home/Login.cshtml")]
    [global::Microsoft.AspNetCore.Razor.Hosting.RazorSourceChecksumAttribute(@"SHA1", @"0890da2bea6a613c6fe5116e779293221719f1ee", @"/Views/_ViewImports.cshtml")]
    public class Views_Home_Login : global::Microsoft.AspNetCore.Mvc.Razor.RazorPage<dynamic>
    {
        private static readonly global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute __tagHelperAttribute_0 = new global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute("src", new global::Microsoft.AspNetCore.Html.HtmlString("~/CustomJS/jquery.js"), global::Microsoft.AspNetCore.Razor.TagHelpers.HtmlAttributeValueStyle.DoubleQuotes);
        private static readonly global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute __tagHelperAttribute_1 = new global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute("href", new global::Microsoft.AspNetCore.Html.HtmlString("~/CustomCSS/jquery-ui.css"), global::Microsoft.AspNetCore.Razor.TagHelpers.HtmlAttributeValueStyle.DoubleQuotes);
        private static readonly global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute __tagHelperAttribute_2 = new global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute("rel", new global::Microsoft.AspNetCore.Html.HtmlString("stylesheet"), global::Microsoft.AspNetCore.Razor.TagHelpers.HtmlAttributeValueStyle.DoubleQuotes);
        private static readonly global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute __tagHelperAttribute_3 = new global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute("src", new global::Microsoft.AspNetCore.Html.HtmlString("~/CustomJS/jquery-ui.min.js"), global::Microsoft.AspNetCore.Razor.TagHelpers.HtmlAttributeValueStyle.DoubleQuotes);
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
        private global::Microsoft.AspNetCore.Mvc.Razor.TagHelpers.UrlResolutionTagHelper __Microsoft_AspNetCore_Mvc_Razor_TagHelpers_UrlResolutionTagHelper;
        private global::Microsoft.AspNetCore.Mvc.Razor.TagHelpers.BodyTagHelper __Microsoft_AspNetCore_Mvc_Razor_TagHelpers_BodyTagHelper;
        #pragma warning disable 1998
        public async override global::System.Threading.Tasks.Task ExecuteAsync()
        {
#nullable restore
#line 1 "C:\Temp\VisualStudio Source\GeminiProjectMaster\Gemini-Archive-SearchWebApp\GeminiSearchWebApp\Views\Home\Login.cshtml"
  

    ViewBag.title = "Login";

#line default
#line hidden
#nullable disable
            __tagHelperExecutionContext = __tagHelperScopeManager.Begin("head", global::Microsoft.AspNetCore.Razor.TagHelpers.TagMode.StartTagAndEndTag, "bdf9de882082d6dd75654b636348ce75cc2a7a285141", async() => {
                WriteLiteral("\r\n    <title>Login Page</title>\r\n    ");
                __tagHelperExecutionContext = __tagHelperScopeManager.Begin("script", global::Microsoft.AspNetCore.Razor.TagHelpers.TagMode.StartTagAndEndTag, "bdf9de882082d6dd75654b636348ce75cc2a7a285436", async() => {
                }
                );
                __Microsoft_AspNetCore_Mvc_Razor_TagHelpers_UrlResolutionTagHelper = CreateTagHelper<global::Microsoft.AspNetCore.Mvc.Razor.TagHelpers.UrlResolutionTagHelper>();
                __tagHelperExecutionContext.Add(__Microsoft_AspNetCore_Mvc_Razor_TagHelpers_UrlResolutionTagHelper);
                __tagHelperExecutionContext.AddHtmlAttribute(__tagHelperAttribute_0);
                await __tagHelperRunner.RunAsync(__tagHelperExecutionContext);
                if (!__tagHelperExecutionContext.Output.IsContentModified)
                {
                    await __tagHelperExecutionContext.SetOutputContentAsync();
                }
                Write(__tagHelperExecutionContext.Output);
                __tagHelperExecutionContext = __tagHelperScopeManager.End();
                WriteLiteral("\r\n    ");
                __tagHelperExecutionContext = __tagHelperScopeManager.Begin("link", global::Microsoft.AspNetCore.Razor.TagHelpers.TagMode.SelfClosing, "bdf9de882082d6dd75654b636348ce75cc2a7a286535", async() => {
                }
                );
                __Microsoft_AspNetCore_Mvc_Razor_TagHelpers_UrlResolutionTagHelper = CreateTagHelper<global::Microsoft.AspNetCore.Mvc.Razor.TagHelpers.UrlResolutionTagHelper>();
                __tagHelperExecutionContext.Add(__Microsoft_AspNetCore_Mvc_Razor_TagHelpers_UrlResolutionTagHelper);
                __tagHelperExecutionContext.AddHtmlAttribute(__tagHelperAttribute_1);
                __tagHelperExecutionContext.AddHtmlAttribute(__tagHelperAttribute_2);
                await __tagHelperRunner.RunAsync(__tagHelperExecutionContext);
                if (!__tagHelperExecutionContext.Output.IsContentModified)
                {
                    await __tagHelperExecutionContext.SetOutputContentAsync();
                }
                Write(__tagHelperExecutionContext.Output);
                __tagHelperExecutionContext = __tagHelperScopeManager.End();
                WriteLiteral("\r\n    ");
                __tagHelperExecutionContext = __tagHelperScopeManager.Begin("script", global::Microsoft.AspNetCore.Razor.TagHelpers.TagMode.StartTagAndEndTag, "bdf9de882082d6dd75654b636348ce75cc2a7a287713", async() => {
                }
                );
                __Microsoft_AspNetCore_Mvc_Razor_TagHelpers_UrlResolutionTagHelper = CreateTagHelper<global::Microsoft.AspNetCore.Mvc.Razor.TagHelpers.UrlResolutionTagHelper>();
                __tagHelperExecutionContext.Add(__Microsoft_AspNetCore_Mvc_Razor_TagHelpers_UrlResolutionTagHelper);
                __tagHelperExecutionContext.AddHtmlAttribute(__tagHelperAttribute_3);
                await __tagHelperRunner.RunAsync(__tagHelperExecutionContext);
                if (!__tagHelperExecutionContext.Output.IsContentModified)
                {
                    await __tagHelperExecutionContext.SetOutputContentAsync();
                }
                Write(__tagHelperExecutionContext.Output);
                __tagHelperExecutionContext = __tagHelperScopeManager.End();
                WriteLiteral(@"
    <script type=""text/javascript"">
        var aLoginId;
        var aPwd;
        $(document).ready(function () {
            $(""#btnLogin"").click(function () {
                if (document.getElementById(""login_id"").value.length == 0 && document.getElementById(""pwd"").value.length == 0) {
                    alert('");
#nullable restore
#line 16 "C:\Temp\VisualStudio Source\GeminiProjectMaster\Gemini-Archive-SearchWebApp\GeminiSearchWebApp\Views\Home\Login.cshtml"
                      Write(ViewBag.emptyCredentials);

#line default
#line hidden
#nullable disable
                WriteLiteral("\');\r\n                }\r\n                else if (document.getElementById(\"login_id\").value.length == 0) {\r\n                    alert(\'");
#nullable restore
#line 19 "C:\Temp\VisualStudio Source\GeminiProjectMaster\Gemini-Archive-SearchWebApp\GeminiSearchWebApp\Views\Home\Login.cshtml"
                      Write(ViewBag.emptyLogin);

#line default
#line hidden
#nullable disable
                WriteLiteral("\');\r\n                }\r\n                else if (document.getElementById(\"pwd\").value.length == 0) {\r\n                    alert(\'");
#nullable restore
#line 22 "C:\Temp\VisualStudio Source\GeminiProjectMaster\Gemini-Archive-SearchWebApp\GeminiSearchWebApp\Views\Home\Login.cshtml"
                      Write(ViewBag.emptyPwd);

#line default
#line hidden
#nullable disable
                WriteLiteral(@"');
                }
                else {
                    $(""#errorMsg"").html("""");
                    document.getElementById(""loading"").innerHTML = ""Loading..."";
                    $(""#btnLogin"").attr(""disabled"", true);
                    aLoginId = $(""#login_id"").val();
                    aPwd = $(""#pwd"").val();
                    var statusResult = false;
                    $.ajax(
                        {
                            type: ""POST"",
                            url: ""/Home/ValidateLogin"",
                            dataType: ""JSON"",
                            data: { userName: aLoginId, password: aPwd },
                            success: function (result) {
                                if (result != null) {
                                    statusResult = true;
                                    $.ajax(
                                        {
                                            type: ""POST"",
                                            ur");
                WriteLiteral(@"l: ""/Home/LoginCheck"",
                                            dataType: ""JSON"",
                                            data: { loginStatus: statusResult },
                                            success: function (result) {
                                            },
                                            error: function () {
                                                writeLogFileFromView(""Error from LoginStatus"");
                                            }
                                        });
                                    window.location.href = ""/Home/SearchCases/?name="" + result;
                                }
                                else {
                                    document.getElementById(""loading"").innerHTML = "" "";
                                    $(""#btnLogin"").attr(""disabled"", false);
                                    $(""#errorMsg"").html(""You are not authorized to view this page"");
                                }
   ");
                WriteLiteral(@"                         },
                            error: function () {
                                writeLogFileFromView(""Error from Login"");
                            }
                        });
                }

            });
            function writeLogFileFromView(exFromView) {
                $.ajax(
                    {
                        type: ""POST"",
                        url: ""/Home/ExceptionMessageFromView"",
                        dataType: ""JSON"",
                        data: { exView: exFromView },
                        success: function (result) {
                            if (result == ""success"") {
                                console.log(""success from View"")
                            }
                            else {
                                console.log(""error"")
                            }
                        },
                        error: function () {
                            console.log(""error from View"");
   ");
                WriteLiteral(@"                     }
                    });
            }
        });
    </script>
    <style>
        html, body {
            width: 100%;
        }

        label {
            color: red;
            font-family: 'Times New Roman';
            font-style: normal;
            font-weight: bold;
        }

        table {
            margin: 0;
            position: absolute;
            top: 50%;
            left: 50%;
            -ms-transform: translate(-50%,-50%);
            transform: translate(-50%,-50%);
            background-color: aliceblue;
            font-size: 20px;
            font-family: 'Times New Roman';
            font-style: normal;
            font-weight: bold;
            text-align: center;
        }

        td {
            padding: 20px;
        }

        .textBoxInput {
            height: 40px;
            width: 300px;
            outline: thick;
        }
        #loading {
            font-family: 'Times New Roman';
         ");
                WriteLiteral(@"   font-style: normal;
            font-weight: bolder;
            text-align: center;
        }

        #btnLogin {
            padding: 0px 20px 0px 20px;
            font-size: 18px;
            font-weight: bold;
            margin: 10px 10px 10px 10px;
            width: 150px;
        }

            #btnLogin:hover {
                background-color: lightskyblue;
            }
            #btnLogin:disabled {
                background-color: lightskyblue;
            }

    </style>
");
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
            WriteLiteral("\r\n");
            __tagHelperExecutionContext = __tagHelperScopeManager.Begin("body", global::Microsoft.AspNetCore.Razor.TagHelpers.TagMode.StartTagAndEndTag, "bdf9de882082d6dd75654b636348ce75cc2a7a2815810", async() => {
                WriteLiteral(@"
    <div style=""vertical-align:middle;"">
        <table style=""align-content: center; border: 1px solid black; border-width: thick;"">
            <tr>
                <td align=""left"" style=""padding-right:20px;"">Username:</td>
                <td><input id=""login_id"" type=""text"" class=""textBoxInput"" placeholder=""Enter Login ID"" /></td>
            </tr>
            <tr>
                <td align=""left"" style=""padding-right: 20px; padding-top: 0px;"">Password:</td>
                <td style=""padding-top:0px;"">
                    <input id=""pwd"" type=""password"" class=""textBoxInput"" placeholder=""Enter Password"" /></td>
            </tr>
            <tr>
                <td colspan=""2"" align=""center"" style=""padding-top:0px;"">
                    <button id=""btnLogin"" name=""btnLogin"" type=""submit"">Sign In</button>
                </td>
            </tr>
            <tr style=""line-height:0px"">
                <td colspan=""2"" style=""padding-top:0px;"">
                    <span id=""loading""></spa");
                WriteLiteral("n>\r\n                    <label id=\"errorMsg\" />\r\n                </td>\r\n            </tr>\r\n        </table>\r\n        <span id=\"loading\"></span>\r\n    </div>\r\n");
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
