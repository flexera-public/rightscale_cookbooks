# An error meaning the VirtualMonkey framework or test collateral has done
# something unexpected.
#
class AssertionError < VirtualMonkey::TestCase::ErrorBase
end

# An error when the command executed using probe returns a non-zero exit code.
#
class FailedProbeCommandError < VirtualMonkey::TestCase::ErrorBase
end

# An error with monitoring plugins.
#
class MonitoringError < VirtualMonkey::TestCase::ErrorBase
end

# An error with selecting a set of servers.
#
class SelectSetError < VirtualMonkey::TestCase::ErrorBase
end

# An error when a timeout occurs.
#
class TimeoutError < VirtualMonkey::TestCase::ErrorBase
end
