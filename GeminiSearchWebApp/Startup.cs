using GeminiSearchWebApp.DAL;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using System;


namespace GeminiSearchWebApp
{
    public class Startup
    {
        public ConnectionClass connectionClass;

        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            try
            {
                services.AddControllersWithViews();
                services.AddDistributedMemoryCache();
                services.AddSession();
                services.AddMvc().AddRazorPagesOptions(options =>
                {
                    options.Conventions.AddPageRoute("/Home/Login", "");
                });
                
            }
            catch (Exception ex)
            {
                connectionClass.CreateMessageLog(ex.Message);
            }

        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            app.UseForwardedHeaders(new ForwardedHeadersOptions
            {
                ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto
            });
            try
            {
                if (env.IsProduction())
                {
                    app.UseDeveloperExceptionPage();
                }
                else
                {
                    app.UseExceptionHandler("/Home/Error");                    
                    app.UseHsts();
                }               
                app.UseStaticFiles();
                app.UseAntiXssMiddleware();
                app.UseSession();
                app.UseRouting();               
                app.UseEndpoints(endpoints =>
                {
                    endpoints.MapControllerRoute(
                        name: "default",
                        pattern: "{controller=Home}/{action=Login}/{id?}");
                });

            }
            catch (Exception ex)
            {
                connectionClass.CreateMessageLog(ex.Message);
            }
           
        }
    }
}
