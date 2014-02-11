package org.realityforge.gwt.sample.contacts.server.service;

import org.realityforge.gwt.sample.contacts.server.ContactsRepositoryModule;
import org.realityforge.gwt.sample.contacts.server.service.contacts.ContactsService;
import com.google.inject.AbstractModule;
import com.google.inject.Guice;
import com.google.inject.Injector;
import org.junit.Assert;
import org.junit.Test;
import org.realityforge.guiceyloops.JEETestingModule;

public class ContactsEJBTest
{
  @Test
  public void testContactsEJB()
  {
    Injector injector = Guice.createInjector( new TestModule(),
                                              new ContactsRepositoryModule(),
                                              new EJBTestingModule( "CONTACTS" ),
                                              new JEETestingModule() );
    final ContactsService _contacts = injector.getInstance( ContactsService.class );
    Assert.assertEquals( 22, _contacts.getContactDetails().size() );
  }

  public static class TestModule
    extends AbstractModule
  {
    protected void configure()
    {
      bind( ContactsService.class ).to( ContactsEJB.class );
    }
  }
}

