class GithubOrganizationMemberAuthenticator
  ORGANIZATION = ENV['GITHUB_ORGANIZATION']

 def initialize(access_token, username)
    @access_token = access_token
    @username = username
  end

  def authenticate
    organization_logins.include?(ORGANIZATION.downcase)
  end

  private
  def organizations
    @organizations = client.organizations(@username)
  end

  def organization_logins
    @organization_logins = organizations.map { |org| org.login.downcase }
  end

  def client
    @client = Octokit::Client.new(access_token: @access_token)
  end
end
