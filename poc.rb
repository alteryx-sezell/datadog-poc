require 'rubygems'
require 'dogapi'

$tags_executor = ["role:executor"]
$tags_results = ["role:result"]

def mock_test (dog, name, host, result)
  et = Random.rand(30) + 5

  sleep(et)
  dog.emit_event(Dogapi::Event.new("#{name} result entered of #{result.to_s} on #{host}", :msg_title => "Test result for #{name}"), :tags => $tags_executor)
  dog.emit_point('test.result',result , :host => host, :tags => $tags_executor)
  dog.emit_point('test.execution_time',et, :host => host, :tags => $tags_executor)
  dog.emit_point('test.result.count',1 , :host => host, :tags => $tags_executor)
  dog.add_tags(name, $tags_results)
  dog.emit_point('test.result',result , :host => name, :tags => $tags_results)
  dog.emit_point('test.execution_time',et, :host => name, :tags => $tags_results)
end

def mock_host_start(dog, host)
  dog.emit_event(Dogapi::Event.new("#{host} ready to start tests", :msg_title => "FRAMEWORK HOST START #{host}", :tags => $tags_executor))
  dog.add_tags(host, $tags_executor)
end

def mock_host_stop(dog, host)
  dog.emit_event(Dogapi::Event.new("#{host} finished executing tests", :msg_title => "FRAMEWORK HOST FINISHED #{host}", :tags => $tags_executor))
end

api_key = "753d728112ab25091bb060c48da039a5"
app_key = "75e3c876f062712baf8f676d0bbc44b70ff9e380"

dog = Dogapi::Client.new(api_key, app_key)
host = "#{Socket.gethostname}.#{ARGV[2]}"
prefix = "agent-#{ARGV[0]}-"
iterations = ARGV[1].to_i

mock_host_start(dog, host)
puts "Doing some mock tests for agent=[#{prefix}] host=[#{host}] #=[#{iterations}]"

(1..iterations).each do |i|
  puts "Executing mock test #{i}"
  mock_test(dog, "#{prefix}#{i}", host,Random.rand(4))
  sec = 5
  puts "Sleeping for #{sec} seconds"
  sleep (sec)
end

mock_host_stop(dog, host)


# Submit multiple metric values
# points = [[Time.now, 0], [Time.now + 10, 10.0], [Time.now + 20, 20.0]]
# dog.emit_points('some.metric.name', points, :tags => ["version:1"])



# Emit differents metrics in a single request to be more efficient
# dog.batch_metrics do
#   dog.emit_point('test.api.test_metric',10)
#   dog.emit_point('test.api.this_other_metric', 1, :type => 'counter')
# end

