puts "Cloud Golem EC2 Instance Shutdown Script Started..."

require 'aws-sdk-ec2'  # v2: require 'aws-sdk'
require_relative 'ec2-credentials.rb'

client = Aws::EC2::Client.new(
  access_key_id: cloud_golem_ec2_access_key_id,
  secret_access_key: cloud_golem_ec2_secret_access_key,
  region: 'us-east-1'
)

ec2 = Aws::EC2::Resource.new(
  client: client
)

i = ec2.instance(cloud_golem_ec2_instance_id)

if i.exists?
  case i.state.code
  when 48  # terminated
    puts "#{cloud_golem_ec2_instance_id} is terminated, so you cannot stop it"
  when 64  # stopping
    puts "#{cloud_golem_ec2_instance_id} is stopping, so it will be stopped in a bit"
  when 80  # stopped
    puts "#{cloud_golem_ec2_instance_id} is already stopped"
  else
    puts "Stopping instance with ID #{cloud_golem_ec2_instance_id}. Current state code: #{i.state.code}"
    i.stop
    puts "Instance stopping..."
  end
end

c = 60

60.times {
  if (c % 10 == 0)
    puts "#{c} seconds elapsed"
  end

  c -= 1
  sleep 1
}

if i.exists?
  case i.state.code
  when 48  # terminated
    puts "There was a problem stopping instance ID #{cloud_golem_ec2_instance_id}..."
    puts "#{cloud_golem_ec2_instance_id} is terminated, so it could not be stopped."
  when 64  # stopping
    puts "There was a problem stopping instance ID #{cloud_golem_ec2_instance_id}..."
    puts "#{cloud_golem_ec2_instance_id} is still stopping."
  when 80  # stopped
    puts "#{cloud_golem_ec2_instance_id} has successfully been stopped."
  else
    puts "There was an unknown problem (state code: #{i.state.code}) stopping instance ID #{cloud_golem_ec2_instance_id}..."
  end
end

puts "Cloud Golem EC2 Instance Shutdown Script Terminated..."
