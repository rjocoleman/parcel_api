require 'parcel_api'

# configure the client
client = ParcelApi::Client.new.tap do |config|
  config.client_id     = ENV['CLIENT_ID']
  config.client_secret = ENV['CLIENT_SECRET']
  config.username      = ENV['USERNAME']
  config.password      = ENV['PASSWORD']
  config.address       = 'https://api.uat.nzpost.co.nz/'
end


# Address examples

query = '151 vic'
address = ParcelApi::Address.new
# search for the query, 3 results
results = address.search(query, 3)
puts "Address Search: #{query}"
puts "Results:"
# dump the results out
puts results.map {|r| r.full_address}

# get details for the first result
puts 'First Address Details:'
details = address.details(results.first.address_id)

# dump the detail parts out
details.to_h.each {|k, v| puts "#{k}: #{v}"}

intl_query = '38 Lap'
# search for the query, defult number of results
intl_results = address.international_search(intl_query)
puts "International Address Search: #{query}"
puts "Results:"
puts intl_results.map {|r| r.full_address}

# get details for the first result
puts 'First International Address Details:'
intl_details = address.international_details(intl_results.first.address_id)

# dump the detail parts out
intl_details.to_h.each {|k, v| puts "#{k}: #{v}"}


# Tracking Example

tracking = ParcelApi::Track.new
results = tracking.details('8144152543878001AKL002PN')

# example tracking output
last_event = results.tracking_events.last
puts results.carrier
puts results.service
puts last_event.event_datetime.to_s + ' ' + last_event.event_description


# Labelling example

labeller = ParcelApi::Label.new

# Label options
cp_label_options = {
  orientation: 'landscape',
  requests: [
    {
      carrier: 'COURIERPOST',
      sender_details: {
        name: 'Glenn Dodd',
        phone: '0274123456',
        email: 'glenn@example.co.nz',
        reference: '654334',
      },
      pickup_address: {
        company: 'Glenns Acme Company',
        city: 'Auckland',
        floor: 'Floor 2',
        postcode: '2102',
        street: '25 Buller Crescent',
        suburb: 'Manurewa',
        unit_type: 'Flat',
        unit_value: '2',
      },
      receiver_details: {
        name: 'Glenn Dodd',
        phone: '0274123456',
      },
      delivery_address: {
        company: 'Acme Company',
        city: 'Auckland',
        floor: 'Floor 2',
        postcode: '2102',
        street: '151 Victoria Street',
        suburb: 'Manurewa',
        unit_type: 'Flat',
        unit_value: '2',
      },
      return_indicator: 'NORMAL',
      delivery_instructions: 'Dont feed my dog tonight',
      service_code: 'CPOLE',
      add_ons: [],
      dimensions: {
        weight: '10',
        height: '35',
        width: '45',
        length: '15',
      }
    }
  ]
}

# create the label
cp = labeller.create(cp_label_options)

# get the label details
details = labeller.details(cp.label_id)

# Print the tracking references
details.tracking_reference.map {|tr| puts tr}
# download the ticket
cp_ticket = labeller.download(cp.label_id)

# Write the ticket out
File.open("#{cp.label_id}.pdf", 'w') do |f|
  f.puts(cp_ticket.read)
end

# International Labelling Example

intl_labeller = ParcelApi::Label.new

# Label options
intl_label_options = {
  requests: [
    {
      sender_details: {
        name: 'The sender',
        phone: '091428774',
        email: 'the_sender@mail.com',
        reference: 'Glqddd 008',
        signatory: 'Mary Jones',
        customs_code: 'HGD34373',
      },
      pickup_address: {
        building: '',
        company: 'Express Courier Limited',
        street: '151 Victoria Street West',
        suburb: 'Auckland Central',
        city: 'Auckland',
        country_code: 'NZ',
        postcode: '1070',
      },
      receiver_details: {
        name: 'Tom Smith',
        phone: '051236547',
        vat_number: 'GB123123123123',
      },
      delivery_address: {
        building: '',
        company: 'American Express',
        street: '23 Broadway Street',
        suburb: 'Queens',
        city: 'New York',
        postcode: '4414',
        country_code: 'US',
        state: 'New York',
      },
      delivery_instructions: 'Leave at door',
      dimensions: {
        length: 600,
        width: 100,
        height: 200
      },
      undeliverable_instructions: 'RETURN',
      contents: [
        {
          unit_description: 'Light bulbs',
          unit_count: 2,
          unit_value: 5.1,
          unit_weight: 0.5,
        },
        {
          unit_description: 'Lego',
          unit_count: 10,
          unit_value: 6.1,
          unit_weight: 0.6,
        },
        {
          unit_description: 'Hot wheels',
          unit_count: 13,
          unit_value: 5.4,
          unit_weight: 0.8,
        }
      ],
      service_code: 'TIEX',
      indicia_number: '123456',
      insurance_required: true,
      contains_only_documents: true,
      export_type: 'Documents',
      harmonised_system_tariff: '12121212',
      user_reference_code: SecureRandom.hex(1),
    }
  ]
}

# create the label
intl = intl_labeller.international_create(intl_label_options)

# get the label details
intl_details = intl_labeller.details(intl.label_id)

# Print the tracking references
intl_details.tracking_reference.map {|tr| puts tr}
# download the ticket
intl_ticket = intl_labeller.download(intl.label_id)

# Write the ticket out
File.open("#{intl.label_id}.pdf", 'w') do |f|
  f.puts(intl_ticket.read)
end


## ShippingOptions Example

shipping_options = ParcelApi::ShippingOptions.new

params = {
  weight: 10,
  length: 10,
  width: 10,
  height: 10,
  pickup_address_id: 990003,
  delivery_dpid: 2727895,
}

domestic_options = shipping_options.get_domestic(params)
domestic_options.to_h.each {|k, v| puts "#{k}: #{v}"}

intl_params = {
  value: 100,
  length: 10,
  height: 10,
  width: 10,
  weight: 13,
  country_code: 'AU',
}

intl_options = shipping_options.get_international(intl_params)
intl_options.to_h.each {|k, v| puts "#{k}: #{v}"}

# Pickup Example

pickup_params = {
  carrier: 'CourierPost',
  caller: 'Test Caller',
  account_number: '91327067',
  pickup_address: {
    site_code: '28979',
    instructions: 'TEST'
  },
  pickup_date_time: '2015-05-28T17:00:00',
  quantity: 1
}

pickup = ParcelApi::Pickup.new(client.connection) # use a custom connection
pickup_results = pickup.create(pickup_params)
pickup_results.to_h.each {|k, v| puts "#{k}: #{v}"}

# Notification Example

notification_params = {
  tracking_reference: 'LE123454152NZ',
  email: 'j.receiver@example.com',
  receiver_first_name: 'John',
  receiver_last_name: 'Receiver',
  collection_location_id: '84320',
}

notification = ParcelApi::Notification.new
notification_results = notification.create(notification_params)
notification_results.to_h.each {|k, v| puts "#{k}: #{v}"}
