Domgen.repository(:Contacts) do |repository|
  repository.enable_facet(:sql)
  repository.enable_facet(:jpa)
  repository.enable_facet(:ejb)
  repository.enable_facet(:gwt)
  repository.enable_facet(:imit)
  repository.enable_facet(:ee)

  repository.gwt.module_name = "contacts"
  repository.gwt.package = 'com.google.gwt.sample.contacts'
  repository.ee.package = 'com.google.gwt.sample.contacts.shared'
  repository.imit.entity_package = 'com.google.gwt.sample.contacts.client.entity'
  repository.imit.encoder_package = 'com.google.gwt.sample.contacts.server.entity'

  repository.data_module(:Contacts) do |data_module|
    data_module.ee.data_type_package = 'com.google.gwt.sample.contacts.shared.data_type'
    data_module.jpa.entity_package = 'com.google.gwt.sample.contacts.server.entity'
    data_module.imit.entity_package = 'com.google.gwt.sample.contacts.client.entity'
    data_module.ejb.service_package = 'com.google.gwt.sample.contacts.server.service'

    data_module.struct(:ContactDetailsDTO) do |ss|
      ss.text(:ID)
      ss.text(:Type)
      ss.text(:DisplayName)
    end

    data_module.struct(:ContactDTO) do |ss|
      ss.text(:ID, :nullable => true)
      ss.text(:Type, :nullable => true)
      ss.text(:FirstName)
      ss.text(:LastName)
      ss.text(:EmailAddress)
    end

    data_module.service(:ContactsService) do |s|
      s.description("Contacts Service definition")

      s.method(:DeleteContacts) do |m|
        m.text(:ID, :collection_type => :sequence)
      end
      s.method(:GetContactDetails) do |m|
        m.returns(:struct,
                  :struct => data_module.struct_by_name(:ContactDetailsDTO),
                  :collection_type => :sequence)
      end
      s.method(:GetContact) do |m|
        m.string(:ID, 50)
        m.returns(:struct, :struct => data_module.struct_by_name(:ContactDTO))
      end
      s.method(:CreateOrUpdateContact) do |m|
        m.struct(:Contact, :ContactDTO)
        m.returns(:struct, :struct => data_module.struct_by_name(:ContactDTO))
      end
    end

    data_module.entity(:ContactType) do |t|
      t.integer(:ID, :primary_key => true)
      t.string(:Name, 50)
      t.string(:RenderCode, 50)

      t.jpa.query("Name", "O.Name = :Name", :multiplicity => :zero_or_one)
    end

    data_module.entity(:Contact) do |t|
      t.integer(:ID, :primary_key => true)
      t.reference(:ContactType)
      t.string(:FirstName, 500, :nullable => true)
      t.string(:LastName, 500, :nullable => true)
      t.string(:EmailAddress, 500, :nullable => true)
    end

    data_module.message(:AddContact)
    data_module.message(:ContactDeleted)
    data_module.message(:ContactUpdated) do |m|
      m.string(:ID, 50)
    end
    data_module.message(:AddContactCancelled)
    data_module.message(:EditContactCancelled) do |m|
      m.string(:ID, 50)
    end
    data_module.message(:ShowContact) do |m|
      m.string(:ID, 50)
    end
    data_module.message(:ContactClosed) do |m|
      m.string(:ID, 50)
    end
    data_module.message(:EditContact) do |m|
      m.string(:ID, 50)
    end

  end
end
