require 'httparty'

def create_insightly_contact(token, data_encoding_id)
  insightly_start = Time.now

  contact_data = {
    'FIRST_NAME'     => 'Simple',
    'LAST_NAME'      => 'Insightly Contact',
    'WORK_EMAILS'    => ['simple@insightly.com'],
    'TWITTER'        => ['insightlyapp'],
    'LINKEDIN'       => ['https://www.linkedin.com/company/insightly'],
    'WORK_ADDRESSES' => [{
      'STREET'   => '434 Brannan St',
      'CITY'     => 'San Francisco',
      'STATE'    => 'California',
      'POSTCODE' => '94107'
    }]
  }

  rsp = HTTParty.post("https://simpleapi.io/v1/Contacts",
    :body => {
      :data => contact_data,
      :data_encoding_id => data_encoding_id
    }.to_json,
    :headers => {
      'Authorization' => "Token #{token}",
      'Content-Type'  => 'application/json'
    }
  )

  request_id = rsp['results']['request_id']

  loop do
    rsp = HTTParty.get("https://simpleapi.io/v1/app/requests/#{request_id}",
      :headers => {
        'Authorization' => "Token #{token}",
        'Content-Type'  => 'application/json'
      }
    )
    break if rsp['status'] == 'processed'
  end

  contact_id = rsp['results'].first['CONTACT_ID']
  puts "Created contact #{contact_id}"

  rsp = HTTParty.get("https://simpleapi.io/v1/Contacts",
    :body => {
      :created_since    => insightly_start.strftime('%FT%T%z'),
      :data_encoding_id => data_encoding_id
    }.to_json,
    :headers => {
      'Authorization' => "Token #{token}",
      'Content-Type'  => 'application/json'
    }
  )

  request_id = rsp['results']['request_id']

  loop do
    rsp = HTTParty.get("https://simpleapi.io/v1/app/requests/#{request_id}",
      :headers => {
        'Authorization' => "Token #{token}",
        'Content-Type'  => 'application/json'
      }
    )
    break if rsp['status'] == 'processed'
  end

  match = rsp['results'].find { |r| r['CONTACT_ID'] == contact_id }
  puts "Contact '#{match['FIRST_NAME']}' was just created"
  insightly_update = Time.now

  rsp = HTTParty.put("https://simpleapi.io/v1/Contacts",
    :body => {
      :data => {
        'CONTACT_ID' => contact_id,
        'FIRST_NAME' => 'Simple Update'
      },
      :data_encoding_id => data_encoding_id
    }.to_json,
    :headers => {
      'Authorization' => "Token #{token}",
      'Content-Type'  => 'application/json'
    }
  )

  request_id = rsp['results']['request_id']

  loop do
    rsp = HTTParty.get("https://simpleapi.io/v1/app/requests/#{request_id}",
      :headers => {
        'Authorization' => "Token #{token}",
        'Content-Type'  => 'application/json'
      }
    )
    break if rsp['status'] == 'processed'
  end

  contact_id = rsp['results'].first['CONTACT_ID']
  puts "Updated contact #{contact_id}"

  rsp = HTTParty.get("https://simpleapi.io/v1/Contacts",
    :body => {
      :updated_since    => insightly_update.strftime('%FT%T%z'),
      :data_encoding_id => data_encoding_id
    }.to_json,
    :headers => {
      'Authorization' => "Token #{token}",
      'Content-Type'  => 'application/json'
    }
  )

  request_id = rsp['results']['request_id']

  loop do
    rsp = HTTParty.get("https://simpleapi.io/v1/app/requests/#{request_id}",
      :headers => {
        'Authorization' => "Token #{token}",
        'Content-Type'  => 'application/json'
      }
    )
    break if rsp['status'] == 'processed'
  end

  match = rsp['results'].find { |r| r['CONTACT_ID'] == contact_id }
  puts "Contact '#{match['FIRST_NAME']}' was just updated"
end
