﻿/*************************************************************************************************/
using Autofac;
using Autofac.Integration.WebApi;
using System.Data.Entity;
using System.Reflection;
using System.Web.Http;
using System.Web.Mvc;
using Takamul.Models;
using Takamul.Services;

namespace Takamul.Portal.App_Start
{
    public class AutofacConfig
    {
        #region Method :: RegisterComponents

        /// <summary>
        /// Register Components 
        /// Will will register all our services to resolve them by Autofac library
        /// </summary>
        public static void RegisterComponents()
        {
            #region Services Container
            var configuration = GlobalConfiguration.Configuration;
            var builder = new ContainerBuilder();
            #endregion

            #region Register Controllers
            // Register API controllers using assembly scanning.
            builder.RegisterApiControllers(Assembly.GetExecutingAssembly());
            #endregion

            #region Generics Service Registrations

            #region Connection Registration

            builder.RegisterType(typeof(TakamulConnection)).As(typeof(DbContext)).InstancePerLifetimeScope();
            #endregion
            #endregion

            #region Custom Service Registration
            builder.RegisterType<NewsServices>().As<INewsServices>().InstancePerLifetimeScope();
            builder.RegisterType<EventService>().As<IEventService>().InstancePerLifetimeScope();
            builder.RegisterType<AuthenticationService>().As<IAuthenticationService>().InstancePerLifetimeScope();
            builder.RegisterType<TicketServices>().As<ITicketServices>().InstancePerLifetimeScope();
            builder.RegisterType<CommonServices>().As<ICommonServices>().InstancePerLifetimeScope();
            builder.RegisterType<ApplicationService>().As<IApplicationService>().InstancePerLifetimeScope();
            builder.RegisterType<UserServices>().As<IUserServices>().InstancePerLifetimeScope();
            #endregion

            #region Register Service Controllers
            // OPTIONAL: Register the Autofac filter provider.
            builder.RegisterWebApiFilterProvider(configuration);

            // Set the dependency resolver to be Autofac.
            var container = builder.Build();
            configuration.DependencyResolver = new AutofacWebApiDependencyResolver(container);
            #endregion

        }

        #endregion
    }
}