# frozen_string_literal: true

require "json"
require "nokogiri"
require "jd/kanjidic/reader"

RSpec.describe JD::Kanjidic::Reader do
  let(:reader) { described_class.new }

  def el(content)
    Nokogiri::XML(content).children.first
  end

  shared_examples "an XML element reader" do
    let(:expected) { nil }

    it "returns an element hash" do
      expect(actual).to eq(expected)
    end

    context "when the element is empty" do
      let(:xml) { "<element />" }

      it "returns nil" do
        expect(actual).to be_nil
      end
    end
  end

  cp_value_xml = <<~XML
    <cp_value cp_type="type1">value1</cp_value>
  XML

  cp_value = { value: "value1", cp_type: "type1" }

  cp_value2_xml = <<~XML
    <cp_value cp_type="type2">value2</cp_value>
  XML

  cp_value2 = { value: "value2", cp_type: "type2" }

  describe "#read_cp_value" do
    subject(:actual) { reader.read_cp_value(el(xml)) }

    let(:xml) { cp_value_xml }

    it_behaves_like "an XML element reader" do
      let(:expected) { cp_value }
    end
  end

  codepoint_xml = <<~XML
    <codepoint>
      #{cp_value_xml}
      #{cp_value2_xml}
    </codepoint>
  XML

  codepoint = { cp_value: [cp_value, cp_value2] }

  describe "#read_codepoint" do
    subject(:actual) { reader.read_codepoint(el(xml)) }

    let(:xml) { codepoint_xml }

    it_behaves_like "an XML element reader" do
      let(:expected) { codepoint }
    end
  end

  rad_value_xml = <<~XML
    <rad_value rad_type="type1">1</rad_value>
  XML

  rad_value = { value: 1, rad_type: "type1" }

  rad_value2_xml = <<~XML
    <rad_value rad_type="type2">2</rad_value>
  XML

  rad_value2 = { value: 2, rad_type: "type2" }

  describe "#read_rad_value" do
    subject(:actual) { reader.read_rad_value(el(xml)) }

    let(:xml) { rad_value_xml }

    it_behaves_like "an XML element reader" do
      let(:expected) { rad_value }
    end
  end

  radical_xml = <<~XML
    <radical>
      #{rad_value_xml}
      #{rad_value2_xml}
    </radical>
  XML

  radical = { rad_value: [rad_value, rad_value2] }

  describe "#read_radical" do
    subject(:actual) { reader.read_radical(el(xml)) }

    let(:xml) { radical_xml }

    it_behaves_like "an XML element reader" do
      let(:expected) { radical }
    end
  end

  variant_xml = <<~XML
    <variant var_type="type1">variant1</variant>
  XML

  variant = { value: "variant1", var_type: "type1" }

  variant2_xml = <<~XML
    <variant var_type="type2">variant2</variant>
  XML

  variant2 = { value: "variant2", var_type: "type2" }

  describe "#read_variant" do
    subject(:actual) { reader.read_variant(el(xml)) }

    let(:xml) { variant_xml }

    it_behaves_like "an XML element reader" do
      let(:expected) { variant }
    end
  end

  misc_xml = <<~XML
    <misc>
      <grade>1</grade>
      <stroke_count>2</stroke_count>
      #{variant_xml}
      #{variant2_xml}
      <freq>3</freq>
      <rad_name>name1</rad_name>
      <rad_name>name2</rad_name>
      <jlpt>4</jlpt>
    </misc>
  XML

  misc = {
    grade: 1,
    stroke_count: [2],
    variant: [variant, variant2],
    freq: 3,
    rad_name: %w[name1 name2],
    jlpt: 4
  }

  describe "#read_misc" do
    subject(:actual) { reader.read_misc(el(xml)) }

    let(:xml) { misc_xml }

    it_behaves_like "an XML element reader" do
      let(:expected) { misc }
    end
  end

  dic_ref_xml = <<~XML
    <dic_ref dr_type="type1">12</dic_ref>
  XML

  dic_ref = { value: 12, dr_type: "type1" }

  dic_ref_moro_xml = <<~XML
    <dic_ref dr_type="moro" m_vol="12" m_page="34">34</dic_ref>
  XML

  dic_ref_moro = { value: 34, dr_type: "moro", m_vol: 12, m_page: 34 }

  describe "#read_dic_ref" do
    subject(:actual) { reader.read_dic_ref(el(xml)) }

    let(:xml) { dic_ref_xml }

    it_behaves_like "an XML element reader" do
      let(:expected) { dic_ref }
    end

    context "when the dr_type is moro" do
      let(:xml) { dic_ref_moro_xml }

      it "returns additional fields" do
        expect(actual).to eq(dic_ref_moro)
      end
    end
  end

  dic_number_xml = <<~XML
    <dic_number>
      #{dic_ref_xml}
      #{dic_ref_moro_xml}
    </dic_number>
  XML

  dic_number = { dic_ref: [dic_ref, dic_ref_moro] }

  describe "#read_dic_number" do
    subject(:actual) { reader.read_dic_number(el(xml)) }

    let(:xml) { dic_number_xml }

    it_behaves_like "an XML element reader" do
      let(:expected) { dic_number }
    end
  end

  q_code_xml = <<~XML
    <q_code qc_type="type">code</q_code>
  XML

  q_code = { value: "code", qc_type: "type" }

  q_code_skip_misclass_xml = <<~XML
    <q_code qc_type="type" skip_misclass="stroke_count">code</q_code>
  XML

  q_code_skip_misclass = {
    value: "code",
    qc_type: "type",
    skip_misclass: "stroke_count"
  }

  describe "#read_q_code" do
    subject(:actual) { reader.read_q_code(el(xml)) }

    let(:xml) { q_code_xml }

    it_behaves_like "an XML element reader" do
      let(:expected) { q_code }
    end

    context "when the skip_misclass attribute is present" do
      let(:xml) { q_code_skip_misclass_xml }

      it "returns additional fields" do
        expect(actual).to eq(q_code_skip_misclass)
      end
    end
  end

  query_code_xml = <<~XML
    <query_code>
      #{q_code_xml}
      #{q_code_skip_misclass_xml}
    </query_code>
  XML

  query_code = { q_code: [q_code, q_code_skip_misclass] }

  describe "#read_query_code" do
    subject(:actual) { reader.read_query_code(el(xml)) }

    let(:xml) { query_code_xml }

    it_behaves_like "an XML element reader" do
      let(:expected) { query_code }
    end
  end

  reading_xml = <<~XML
    <reading r_type="type">reading</reading>
  XML

  reading = { value: "reading", r_type: "type" }

  reading_ja_on_xml = <<~XML
    <reading r_type="ja_on" on_type="kan" r_status="jy">reading</reading>
  XML

  reading_ja_on = {
    value: "reading",
    r_type: "ja_on",
    on_type: "kan",
    r_status: "jy"
  }

  reading_ja_kun_xml = <<~XML
    <reading r_type="ja_kun" r_status="jy">reading</reading>
  XML

  reading_ja_kun = { value: "reading", r_type: "ja_kun", r_status: "jy" }

  describe "#read_reading" do
    subject(:actual) { reader.read_reading(el(xml)) }

    let(:xml) { reading_xml }

    it_behaves_like "an XML element reader" do
      let(:expected) { reading }
    end

    context "when the r_type is ja_on" do
      let(:xml) { reading_ja_on_xml }

      it "returns additional attributes" do
        expect(actual).to eq(reading_ja_on)
      end
    end

    context "when the r_type is ja_kun" do
      let(:xml) { reading_ja_kun_xml }

      it "returns additional attributes" do
        expect(actual).to eq(reading_ja_kun)
      end
    end
  end

  meaning_xml = <<~XML
    <meaning m_lang="lang">meaning1</meaning>
  XML

  meaning = { value: "meaning1", m_lang: "lang" }

  meaning2_xml = <<~XML
    <meaning>meaning2</meaning>
  XML

  meaning2 = { value: "meaning2" }

  describe "#read_meaning" do
    subject(:actual) { reader.read_meaning(el(xml)) }

    let(:xml) { meaning_xml }

    it_behaves_like "an XML element reader" do
      let(:expected) { meaning }
    end
  end

  rmgroup_xml = <<~XML
    <rmgroup>
      #{reading_xml}
      #{reading_ja_on_xml}
      #{reading_ja_kun_xml}
      #{meaning_xml}
      #{meaning2_xml}
    </rmgroup>
  XML

  rmgroup = {
    reading: [reading, reading_ja_on, reading_ja_kun],
    meaning: [meaning, meaning2]
  }

  rmgroup2_xml = <<~XML
    <rmgroup>
      <reading r_type="type3">reading3</reading>
      <reading r_type="type4">reading4</reading>
      <meaning>meaning3</meaning>
      <meaning m_lang="lang">meaning4</meaning>
    </rmgroup>
  XML

  rmgroup2 = {
    reading: [
      { value: "reading3", r_type: "type3" },
      { value: "reading4", r_type: "type4" }
    ],
    meaning: [
      { value: "meaning3" },
      { value: "meaning4", m_lang: "lang" }
    ]
  }

  describe "#read_rmgroup" do
    subject(:actual) { reader.read_rmgroup(el(xml)) }

    let(:xml) { rmgroup_xml }

    it_behaves_like "an XML element reader" do
      let(:expected) { rmgroup }
    end
  end

  reading_meaning_xml = <<~XML
    <reading_meaning>
      #{rmgroup_xml}
      #{rmgroup2_xml}
    </reading_meaning>
  XML

  reading_meaning = { rmgroup: [rmgroup, rmgroup2] }

  describe "#read_reading_meaning" do
    subject(:actual) { reader.read_reading_meaning(el(xml)) }

    let(:xml) { reading_meaning_xml }

    it_behaves_like "an XML element reader" do
      let(:expected) { reading_meaning }
    end
  end

  character_xml = <<~XML
    <character>
      <literal>literal</literal>
      #{codepoint_xml}
      #{radical_xml}
      #{misc_xml}
      #{dic_number_xml}
      #{query_code_xml}
      #{reading_meaning_xml}
    </character>
  XML

  character = {
    literal: "literal",
    codepoint:,
    radical:,
    misc:,
    dic_number:,
    query_code:,
    reading_meaning:
  }

  describe "#read_element" do
    subject(:actual) { reader.read_element(el(xml)) }

    let(:xml) { character_xml }

    it_behaves_like "an XML element reader" do
      let(:expected) { character }
    end
  end

  describe "#read_file" do
    subject(:actual) { reader.read_file("spec/jd/kanjidic/kanjidic.xml") }

    it "reads an XML file" do
      expected = JSON.load_file(
        "spec/jd/kanjidic/kanjidic.json",
        { symbolize_names: true }
      )
      expect(actual).to eq(expected)
    end
  end
end
