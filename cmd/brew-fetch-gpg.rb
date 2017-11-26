#:  * `fetch-gpg` <formulae> <GPG signature URL>
#:    Downloads the source packages for the given <formulae>
#:    and attempts to verify them using GnuPG.

require "formula"
require "gpg"
require "utils"

# Full Disclosure: I wrote this mostly messing around on a project I haven't
# yet completely abandoned and consequently have done almost no code tidying
# or deduplication, so yeah, for now this is written kinda hideously.
# Also, obvious workarounds like if this ever becomes part of Homebrew
# proper instead of demanding a URL from the user it'll use variables
# such as `Formula["test"].gpg` to automatically extract that information.
module FetchGpg
  module_function

  raise "Arguments cannot be empty!" if ARGV.named.empty?
  raise "GPG must be installed & available" unless Gpg.available?

  # This is a bit cheeky & should perhaps be moved elsewhere
  # until/if this command ever becomes part of Homebrew officially.
  @gpg_cache = HOMEBREW_CACHE/"gpg_verifications"
  # This should go away sooner rather than later but want to ensure
  # the cache is fresh & any failures are legit rather than local
  # file corruption/etc.
  FileUtils.rm_rf @gpg_cache
  @gpg_cache.mkpath

  def fetch_and_cache
    @formula = Formula[ARGV.first].name.to_s
    # No support for bottle GPG verification yet, obviously.
    system "brew", "fetch", @formula, "--build-from-source"
    @cached_download = Formula[@formula].cached_download
  rescue FormulaUnavailableError
    odie "The first argument passed must be a valid formula"
  end

  def fetch_gpg_url
    url = ARGV.last
    # Add support for file:// here soon. Check compatibility with
    # curl_download usage first, there are some issues there possibly.
    unless ARGV.last.start_with?("https://", "ftp://", "http://")
      raise "GPG signature must come from a URL."
    end
    @cached_sig = @gpg_cache.join("#{@formula}.asc")
    curl_download url, to: @cached_sig
  end

  def verify_signature_validity
    gpg = Gpg.executable
    ohai "Verifying #{Formula[@formula].stable.url}..."
    quiet_system gpg, "--verify", @cached_sig, @cached_download

    if $CHILD_STATUS.exitstatus.zero?
      ohai "GPG signature seems to be valid."
    else
      FileUtils.rm_f @cached_download
      FileUtils.rm_rf @gpg_cache
      # We should probably capture & print the output if there's failure
      # so users have some kind of clue as to what went wrong.
      odie "GPG Verification Failure!"
    end
  end

  fetch_and_cache
  fetch_gpg_url
  verify_signature_validity
end
