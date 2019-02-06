require 'spec_helper'

RSpec.describe Harvesting::Models::Invoices, :vcr do
  let(:attrs) { Hash.new }
  let(:invoices) { Harvesting::Models::Invoices.new(attrs, {}, client: harvest_client) }

  include_context "harvest data setup"

  let(:per_page) { 100 }
  let(:total_entries) { 115 }
  let(:page1_results) do
    entries = []
    100.times { entries.push({}) }
    {
        "invoices" => entries,
        "per_page" => per_page,
        "total_pages" => 2,
        "total_entries" => 115,
        "next_page" => 2,
        "previous_page" => nil,
        "page" => 1
    }
  end

  let(:page2_results) do
    entries = []
    15.times { entries.push({}) }
    {
        invoices: entries,
        per_page: per_page,
        total_pages: 2,
        total_entries: 115,
        next_page: nil,
        previous_page: 1,
        page: 2
    }
  end

  let(:attrs) { page1_results }

  describe "#fetch_next_page" do
    it "provides next page invoices" do
      stub_request(:get, /invoices/).
            with(query: {"page" => "2"}).
            to_return( { body: page2_results.to_json } )

      invoices.send(:fetch_next_page)
      count = 0
      invoices.entries.each { |entry| count += 1 }
      expect(count).to eq 115

      expect(WebMock).to have_requested(:get, /invoices/).
            with(query: {"page" => "2"})
    end
  end

end 