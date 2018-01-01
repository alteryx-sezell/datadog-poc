require 'rubygems'
require 'dogapi'

# Some global values
$tags_executor = ["role:executor"]
$tags_results = ["role:result"]

#some reusable methods
def mock_host_start(dog, host, tags=[])
  dog.add_tags(host, tags) unless tags.empty?
  dog.emit_event(Dogapi::Event.new("#{host} ready to start tests", :msg_title => "FRAMEWORK HOST START #{host}"))
end

def mock_host_stop(dog, host)
  dog.emit_event(Dogapi::Event.new("#{host} finished executing tests", :msg_title => "FRAMEWORK HOST FINISHED #{host}"))
end

def mock_test (dog, host, test, result)

  # #simlulate some time to run a test, use a random number so that it's variable for each client running the mock test
  et = Random.rand(120) + 10
  puts "Executing #{test} for #{et} seconds"
  sleep(et)

  # #send a results event with the details
  dog.emit_event(Dogapi::Event.new("#{test} result entered of #{result.to_s} on #{host} Some detailed explanation goes here...", :msg_title => "FRAMEWORK HOST TEST RESULT #{test}" ))

  dog.emit_point('test.result.count',1 , :host => host, :tags => ["test:#{test}"])
  dog.emit_point("test.result", result, :tags => ["test:#{test}"])
  dog.emit_point('test.execution_time',et, :host => host, :tags => ["test:#{test}"])

end

#main test flow
api_key = "753d728112ab25091bb060c48da039a5"
app_key = "75e3c876f062712baf8f676d0bbc44b70ff9e380"
dog = Dogapi::Client.new(api_key, app_key)

#params host number, suite, # of mock tests to run
host = "#{Socket.gethostname}.#{ARGV[0]}"
suite = "suite.#{ARGV[1]}"
iterations = ARGV[2].to_i

puts "Doing some mock tests host=[#{host}] suite=[#{suite}] #tests=[#{iterations}]"
mock_host_start(dog, host, $tags_executor)


(1..iterations).each do |i|
  test = "#{suite}.#{i}"
  puts "Executing mock test #{test}"
  mock_test(dog,host,test, Random.rand(3)+1)
end

mock_host_stop(dog, host)




