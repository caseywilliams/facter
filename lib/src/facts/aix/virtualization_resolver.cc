#include <internal/facts/aix/virtualization_resolver.hpp>
#include <internal/util/agent.hpp>

using namespace std;

namespace facter { namespace facts { namespace aix {

    std::string virtualization_resolver::get_hypervisor(collection& facts)
    {
        auto hypervisors = facts.get("hypervisors");
        if (!hypervisors.empty()) {
            return hypervisors.rbegin()->first;
        }
        return "physical";
    }

}}}  // namespace facter::facts::aix
