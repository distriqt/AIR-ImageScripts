require 'yaml'
require 'open3'
require 'tmpdir'
require 'fileutils'

repo = File.expand_path('..', __dir__)
action = YAML.load_file(File.join(repo, 'action.yml'))
defaults = action.fetch('inputs').transform_values { |spec| spec.fetch('default', '') }

def run_step(step, context, workspace, temporary, output)
  environment = {
    'GITHUB_WORKSPACE' => workspace,
    'RUNNER_TEMP' => temporary,
    'GITHUB_OUTPUT' => output
  }
  step.fetch('env', {}).each do |key, value|
    environment[key] = value.gsub(/\$\{\{\s*(.*?)\s*\}\}/) { context.fetch(Regexp.last_match(1)) }
  end
  Open3.capture2e(environment, 'bash', '-e', '-o', 'pipefail', '-c', step.fetch('run'))
end

Dir.mktmpdir('air-action-test') do |temporary|
  source = File.join(temporary, 'source images $(false)')
  destination = File.join(temporary, 'generated icons')
  output = File.join(temporary, 'outputs')
  FileUtils.mkdir_p(source)
  FileUtils.cp_r(Dir.glob(File.join(repo, 'example', '*.png')), source)
  assets = File.join(source, '.air-icon-generation-assets-v2', 'src')
  FileUtils.mkdir_p(assets)
  FileUtils.cp_r(File.join(repo, 'src', 'generate-assets', '.'), assets)
  inputs = defaults.merge('source-dir' => source, 'output-dir' => destination)
  context = { 'runner.os' => 'macOS', 'github.action_path' => repo }
  inputs.each { |key, value| context["inputs.#{key}"] = value }
  steps = action.fetch('runs').fetch('steps')

  log, result = run_step(steps.first, context.merge('runner.os' => 'Linux'), repo, temporary, output)
  abort 'FAIL: unsupported runners must fail clearly' if result.success? || !log.include?('requires macOS')

  steps.each do |step|
    log, result = run_step(step, context, repo, temporary, output)
    abort "FAIL: #{step.fetch('name')}\n#{log}" unless result.success?
  end
  expected = "output-dir=#{File.realpath(destination)}"
  abort 'FAIL: normalized output directory' unless File.read(output).strip == expected
  puts 'PASS: action generates validated assets with whitespace and literal shell characters in paths'

  {
    'missing source' => { 'inputs.source-dir' => File.join(temporary, 'missing') },
    'overlapping output' => { 'inputs.output-dir' => source },
    'empty output' => { 'inputs.output-dir' => '' },
    'multiline output' => { 'inputs.output-dir' => "#{destination}\nunexpected=value" }
  }.each do |name, overrides|
    FileUtils.rm_f(output)
    log, result = run_step(steps.last, context.merge(overrides), repo, temporary, output)
    abort "FAIL: #{name} should fail\n#{log}" if result.success?
    abort "FAIL: #{name} published output" if File.exist?(output)
    puts "PASS: #{name} rejected"
  end
end