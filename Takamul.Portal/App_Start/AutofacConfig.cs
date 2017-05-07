/*************************************************************************************************/
using Autofac;
using Autofac.Integration.Mvc;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Reflection;
using System.Web;
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

            var builder = new ContainerBuilder();

            #endregion

            #region Register Controllers

            builder.RegisterControllers(Assembly.GetExecutingAssembly()); // Register Controller Dynamically  

            #endregion

            #region Generics Service Registrations

            #region Connection Registration
            builder.RegisterType(typeof(TakamulConnection)).As(typeof(DbContext)).InstancePerLifetimeScope();

            #endregion

            #endregion

            #region Custom Service Registration

            builder.RegisterType<ApplicationService>().As<IApplicationService>().InstancePerLifetimeScope();
            builder.RegisterType<EventService>().As<IEventService>().InstancePerLifetimeScope();
            builder.RegisterType<NewsServices>().As<INewsServices>().InstancePerLifetimeScope();
            builder.RegisterType<TicketServices>().As<ITicketServices>().InstancePerLifetimeScope();
            builder.RegisterType<MemberInfoService>().As<IMemberInfoService>().InstancePerLifetimeScope();

            #endregion

            #region Register Service Controllers

            //var  _containerProvider = new ContainerProvider(builder.Build());
            //  ControllerBuilder.Current.SetControllerFactory(new AutofacControllerFactory(ContainerProvider));

            var container = builder.Build();
            DependencyResolver.SetResolver(new AutofacDependencyResolver(container));
            #endregion
        }

        #endregion
    }
}