require 'benchmark'
$LOAD_PATH << "lib"

Benchmark.bm(41) do |bm|
  bm.report("Virtus load") do
    require 'virtus'

    class VirtusUser
      include Virtus.model
      attribute :id,         Integer
      attribute :name,       String
      attribute :paid,       Boolean
      attribute :updated_at, DateTime
    end
  end

  bm.report("ModelAttribute load") do
    require_relative 'lib/model_attribute'

    class ModelAttributeUser
      extend ModelAttribute
      attribute :id,         :integer
      attribute :name,       :string
      attribute :paid,       :boolean
      attribute :updated_at, :time
    end
  end
end

Benchmark.bm(41) do |bm|
  vu  = VirtusUser.new
  mau = ModelAttributeUser.new
  bm.report("Virtus         assign integer")             { 10_000.times {  vu.id = rand(100_000) } }
  bm.report("ModelAttribute assign integer")             { 10_000.times { mau.id = rand(100_000) } }
  bm.report("Virtus         assign integer from string") { 10_000.times {  vu.id = rand(100_000).to_s } }
  bm.report("ModelAttribute assign integer from string") { 10_000.times { mau.id = rand(100_000).to_s } }
  bm.report("Virtus         assign time")                { 10_000.times {  vu.updated_at = Time.now } }
  bm.report("ModelAttribute assign time")                { 10_000.times { mau.updated_at = Time.now } }
  bm.report("Virtus         assign DateTime")            { 10_000.times {  vu.updated_at = DateTime.now } }
  bm.report("ModelAttribute assign DateTime")            { 10_000.times { mau.updated_at = DateTime.now } }
  bm.report("Virtus         assign time from epoch")     { 10_000.times {  vu.updated_at = Time.now.to_f } }
  bm.report("ModelAttribute assign time from epoch")     { 10_000.times { mau.updated_at = Time.now.to_f } }
  bm.report("Virtus         assign time from string")    { 10_000.times {  vu.updated_at = "2014-12-25 06:00:00" } }
  bm.report("ModelAttribute assign time from string")    { 10_000.times { mau.updated_at = "2014-12-25 06:00:00" } }
end

__END__
$ ruby -v
ruby 1.9.3p545 (2014-02-24 revision 45159) [x86_64-darwin13.3.0]
$ ruby performance_comparison.rb
                                                user     system      total        real
Virtus load                                0.120000   0.040000   0.160000 (  0.207931)
ModelAttribute load                        0.020000   0.010000   0.030000 (  0.027237)
                                                user     system      total        real
Virtus         assign integer              0.010000   0.000000   0.010000 (  0.013906)
ModelAttribute assign integer              0.030000   0.000000   0.030000 (  0.033674)
Virtus         assign integer from string  0.170000   0.000000   0.170000 (  0.171892)
ModelAttribute assign integer from string  0.050000   0.000000   0.050000 (  0.042726)
Virtus         assign time                 0.080000   0.000000   0.080000 (  0.089792)
ModelAttribute assign time                 0.060000   0.000000   0.060000 (  0.057887)
Virtus         assign DateTime             0.030000   0.000000   0.030000 (  0.026447)
ModelAttribute assign DateTime             0.200000   0.000000   0.200000 (  0.204524)
Virtus         assign time from epoch      0.230000   0.010000   0.240000 (  0.225557)
ModelAttribute assign time from epoch      0.110000   0.000000   0.110000 (  0.113315)
Virtus         assign time from string     0.260000   0.000000   0.260000 (  0.264467)
ModelAttribute assign time from string     0.450000   0.000000   0.450000 (  0.444686)
