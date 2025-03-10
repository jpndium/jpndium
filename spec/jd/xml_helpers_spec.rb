# frozen_string_literal: true

require "nokogiri"
require "jd/xml_helpers"

RSpec.describe JD::XmlHelpers do
  include described_class

  def el(content)
    Nokogiri::XML(content).children.first
  end

  items_xml = [
    "<item>one</item>",
    "<item>two</item>",
    "<item>three</item>",
    "<item></item>"
  ]

  let(:element) { el("<element>#{items_xml.join}</element>") }

  describe "#find_first_content" do
    it "returns the compacted content of the first element found" do
      expect(find_first_content(element, "item")).to eq("one")
    end

    context "when the element is nil" do
      it "returns nil" do
        expect(find_first_content(nil, "item")).to be_nil
      end
    end

    context "when no elements are found" do
      it "returns nil" do
        expect(find_first_content(element, "foobar")).to be_nil
      end
    end
  end

  describe "#find_first" do
    it "returns the first element found" do
      expect(find_first(element, "item").to_html).to eq(items_xml.first)
    end

    context "when the element is nil" do
      it "returns nil" do
        expect(find_first(nil, "item")).to be_nil
      end
    end

    context "when no elements are found" do
      it "returns nil" do
        expect(find_first(element, "foobar")).to be_nil
      end
    end
  end

  describe "#find_content" do
    it "returns an array of each element's compacted content" do
      expect(find_content(element, "item"))
        .to contain_exactly("one", "two", "three")
    end

    context "when the element is nil" do
      it "returns nil" do
        expect(find_content(nil, "item")).to be_nil
      end
    end

    context "when no elements are found" do
      it "returns nil" do
        expect(find_content(element, "foobar")).to be_nil
      end
    end
  end

  describe "#find_map" do
    it "yields each element found to the provided block" do
      expect { |b| find_map(element, "item", &b) }
        .to yield_successive_args(*element.search("item"))
    end

    context "when the element is nil" do
      it "does not yield to the provided block" do
        expect { |b| find_map(nil, "item", &b) }.not_to yield_control
      end
    end

    context "when no elements are found" do
      it "does not yield to the provided block" do
        expect { |b| find_map(element, "foobar", &b) }.not_to yield_control
      end
    end
  end

  describe "#compact_content" do
    let(:element) { el("<element> content </element>") }

    it "returns an element's contents compacted" do
      expect(compact_content(element)).to eq("content")
    end

    context "when the element is nil" do
      it "returns nil" do
        expect(compact_content(nil)).to be_nil
      end
    end
  end

  describe "#compact" do
    context "when the value is nil" do
      it "returns nil" do
        expect(compact(nil)).to be_nil
      end
    end

    context "when the value is empty" do
      it "returns nil" do
        expect(compact("")).to be_nil
      end
    end

    context "when the value responds to #compact" do
      let(:obj) do
        double.tap { |d| allow(d).to receive(:compact).and_return("compacted") }
      end

      it "calls #compact" do
        expect(compact(obj)).to eq("compacted")
      end
    end

    context "when the value can't be compacted" do
      it "returns the value" do
        expect(compact("foobar")).to eq("foobar")
      end
    end
  end
end
