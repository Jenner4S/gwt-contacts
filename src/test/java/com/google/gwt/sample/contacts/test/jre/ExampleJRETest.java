package com.google.gwt.sample.contacts.test.jre;

import com.google.gwt.event.shared.HandlerManager;
import com.google.gwt.sample.contacts.client.ContactsServiceAsync;
import com.google.gwt.sample.contacts.client.common.ColumnDefinition;
import com.google.gwt.sample.contacts.client.presenter.ContactsPresenter;
import com.google.gwt.sample.contacts.client.view.ContactsView;
import com.google.gwt.sample.contacts.shared.ContactDetails;
import com.google.gwt.user.client.rpc.AsyncCallback;
import java.util.ArrayList;
import java.util.List;
import junit.framework.TestCase;
import org.easymock.IAnswer;
import static org.easymock.EasyMock.createStrictMock;
import static org.easymock.EasyMock.expectLastCall;
import static org.easymock.EasyMock.getCurrentArguments;
import static org.easymock.EasyMock.isA;
import static org.easymock.EasyMock.replay;
import static org.easymock.EasyMock.verify;

@SuppressWarnings( "unchecked" )
public class ExampleJRETest
  extends TestCase
{
  private ContactsPresenter contactsPresenter;
  private ContactsServiceAsync mockRpcService;
  private HandlerManager mockEventBus;
  private ContactsView<ContactDetails> mockView;
  private List<ContactDetails> contactDetails;

  protected void setUp()
  {
    mockRpcService = createStrictMock( ContactsServiceAsync.class );
    mockEventBus = new HandlerManager( null );
    mockView = createStrictMock( ContactsView.class );
    contactsPresenter =
      new ContactsPresenter( mockRpcService,
                             mockEventBus,
                             mockView,
                             new ArrayList<ColumnDefinition<ContactDetails>>() );
  }

  public void testDeleteButton()
  {
    contactDetails = new ArrayList<ContactDetails>();
    contactDetails.add( new ContactDetails( "0", "1_contact" ) );
    contactDetails.add( new ContactDetails( "1", "2_contact" ) );
    contactsPresenter.setContactDetails( contactDetails );

    mockRpcService.deleteContacts( isA( ArrayList.class ), isA( AsyncCallback.class ) );

    expectLastCall().andAnswer( new IAnswer()
    {
      public Object answer()
        throws Throwable
      {
        final AsyncCallback callback = getCallback();
        callback.onSuccess( null );
        return null;
      }
    } );

    mockRpcService.getContactDetails( isA( AsyncCallback.class ) );
    expectLastCall().andAnswer( new IAnswer()
    {
      public Object answer()
        throws Throwable
      {
        contactDetails = new ArrayList<ContactDetails>();
        contactDetails.add( new ContactDetails( "0", "1_contact" ) );
        final AsyncCallback callback = getCallback();
        callback.onSuccess( contactDetails );
        return null;
      }
    } );


    replay( mockRpcService );
    contactsPresenter.onDeleteButtonClicked();
    verify( mockRpcService );

    assertEquals( 1, contactsPresenter.getContactDetails().size() );
  }

  private AsyncCallback getCallback()
  {
    final Object[] arguments = getCurrentArguments();
    return (AsyncCallback) arguments[ arguments.length - 1 ];
  }
}