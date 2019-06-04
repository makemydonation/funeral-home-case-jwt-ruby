require 'faker'
require 'jwt'
require 'sinatra'

get '/' do

  # Your Make My Donation API Key
  #
  # You can obtain this key at https://donate.makemydonation.org/user/api
  key = ENV['MMD_API_KEY']

  # Your funeral home id
  #
  # You can obtain a list of available funeral homes doing an API call to
  # https://api.makemydonation.org/v1/funeral_home
  #
  # You can read more about the REST API at
  # https://funeralsmakemydonationorg.docs.apiary.io
  funeral_home_id = ENV['MMD_FH_ID']

  # Your funeral home subdomain
  funeral_home_subdomain = ENV['MMD_FH_SUBDOMAIN']

  # An alpha-numeric internal id for your obit case
  #
  # This id is required and should be unique for each case.
  # You may want to use your own system index id as this value.
  #
  # Your internal id will not conflict with internal ids of other funeral homes
  # so you don't need to prefix it with an identifier unique to you.
  #
  # If you want to update the case data, we use the internal id to identify the
  # desired case to be changed.
  case_internal_id = rand(36**8).to_s(36)

  # The object that will be set as the JWT header
  header = {
    # The supported actions are 'create' or 'create_or_update'
    'action' => 'create_or_update',
    # Your Make My Donation username
    'user' => ENV['MMD_USER'],
    # A timestamp that represents when this case data was last updated
    #
    # This is useful to allow you to update the case without the risk of
    # overriding it with old data if someone access an old version of the link.
    #
    # We suggest you to use the last time the obit data was updated.
    'updated' => Time.now.to_i
  }

  # The obit data
  case_name = [Faker::Name.first_name, Faker::Name.last_name].join(' ')
  case_family_emails = Array.new(rand(0..3)) { Faker::Internet.safe_email }
  case_charities = ['042263040', '620646012', '202370934', '814009548', '530206027', '135563422'].sample(rand(0..6))

  # The object that will be set as the JWT payload
  payload = {
    # The case object
    #
    # You can find more details about this object in our API documentation at
    # https://funeralsmakemydonationorg.docs.apiary.io/#reference/0/funeral-home-cases/create-a-case
    #
    # Please note that, unlike our REST API, the internal_id field is required.
    'case' => {
      'funeral_home' => funeral_home_id,
      'name' => case_name,
      'internal_id' => case_internal_id,
      'family_emails' => case_family_emails,
      'charities' => case_charities
    }
  }

  # The JWT sign algorithm
  #
  # Supported algorithms are 'HS256', 'HS384' and 'HS512'.
  alg = 'HS256'

  token = JWT.encode(payload, key, alg, header)
  donation_link = funeral_home_subdomain + "/funeral_home/" + funeral_home_id.to_s + "/case/internal/" + case_internal_id + "?token=" + token

"
<!DOCTYPE>
<html>
  <head>
    <title>Obituary of " + case_name + "</title>
    <link rel='stylesheet' href='https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css' integrity='sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T' crossorigin='anonymous'>
  </head>
  <body style='text-align: center; margin: 4rem'>
    <h1>Make My Donation - In Memory Of</h1>
    <p class='lead' style='margin-bottom: 5rem'>Inline Funeral Home Case creation with JWT</p>
    <p>
      <a
        class='btn btn-primary'
        target='_blank'
        href='" + donation_link + "'
      >
        Make My Donation in memory of " + case_name + "
      </a>
    </p>
    <div class='card' style='margin: 4rem auto; max-width: 50rem'>
      <ul class='list-group list-group-flush text-secondary'>
        <li class='list-group-item'>Family emails: " + case_family_emails.join(', ') + "</li>
        <li class='list-group-item'>Charities: " + case_charities.join(', ') +"</li>
      </ul>
    </div>
    <hr>
    <p>
    <a href='https://github.com/makemydonation/funeral-home-case-jwt-ruby'>View source on GitHub</a>
    </p>
  </body>
</html>
"
end
