# frozen_string_literal: true

require "jd/kanjidic/reader"

RSpec.describe JD::Kanjidic::Reader do
  let(:xml) do
    codepoint_xml = <<~XML
      <codepoint>
        <cp_value cp_type="type1">value1</cp_value>
        <cp_value cp_type="type2">value2</cp_value>
      </codepoint>
    XML

    radical_xml = <<~XML
      <radical>
        <rad_value rad_type="type1">1</rad_value>
        <rad_value rad_type="type2">2</rad_value>
      </radical>
    XML

    misc_xml = <<~XML
      <misc>
        <grade>1</grade>
        <stroke_count>2</stroke_count>
        <variant var_type="type1">variant1</variant>
        <variant var_type="type2">variant2</variant>
        <freq>3</freq>
        <rad_name>name1</rad_name>
        <rad_name>name2</rad_name>
        <jlpt>4</jlpt>
      </misc>
    XML

    dic_number_xml = <<~XML
      <dic_number>
        <dic_ref dr_type="type1">12</dic_ref>
        <dic_ref dr_type="moro" m_vol="12" m_page="34">34</dic_ref>
      </dic_number>
    XML

    query_code_xml = <<~XML
      <query_code>
        <q_code qc_type="type">code</q_code>
        <q_code qc_type="type" skip_misclass="stroke_count">code</q_code>
      </query_code>
    XML

    reading_meaning_xml = <<~XML
      <reading_meaning>
        <rmgroup>
          <reading r_type="type">reading</reading>
          <reading r_type="ja_on" on_type="kan" r_status="jy">reading</reading>
          <reading r_type="ja_kun" r_status="jy">reading</reading>
          <meaning m_lang="lang">meaning1</meaning>
          <meaning>meaning2</meaning>
        </rmgroup>
        <rmgroup>
          <reading r_type="type3">reading3</reading>
          <reading r_type="type4">reading4</reading>
          <meaning>meaning3</meaning>
          <meaning m_lang="lang">meaning4</meaning>
        </rmgroup>
      </reading_meaning>
    XML

    <<~XML
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
  end

  let(:character) do
    codepoint = {
      cp_value: [
        { value: "value1", cp_type: "type1" },
        { value: "value2", cp_type: "type2" }
      ]
    }

    radical = {
      rad_value: [
        { value: 1, rad_type: "type1" },
        { value: 2, rad_type: "type2" }
      ]
    }

    misc = {
      grade: 1,
      stroke_count: [2],
      variant: [
        { value: "variant1", var_type: "type1" },
        { value: "variant2", var_type: "type2" }
      ],
      freq: 3,
      rad_name: %w[name1 name2],
      jlpt: 4
    }

    dic_number = {
      dic_ref: [
        { value: 12, dr_type: "type1" },
        { value: 34, dr_type: "moro", m_vol: 12, m_page: 34 }
      ]
    }

    query_code = {
      q_code: [
        { value: "code", qc_type: "type" },
        {
          value: "code",
          qc_type: "type",
          skip_misclass: "stroke_count"
        }
      ]
    }

    reading_meaning = {
      rmgroup: [
        {
          reading: [
            { value: "reading", r_type: "type" },
            {
              value: "reading",
              r_type: "ja_on",
              on_type: "kan",
              r_status: "jy"
            },
            { value: "reading", r_type: "ja_kun", r_status: "jy" }
          ],
          meaning: [
            { value: "meaning1", m_lang: "lang" },
            { value: "meaning2" }
          ]
        },
        {
          reading: [
            { value: "reading3", r_type: "type3" },
            { value: "reading4", r_type: "type4" }
          ],
          meaning: [
            { value: "meaning3" },
            { value: "meaning4", m_lang: "lang" }
          ]
        }
      ]
    }

    {
      literal: "literal",
      codepoint:,
      radical:,
      misc:,
      dic_number:,
      query_code:,
      reading_meaning:
    }
  end

  describe ".read" do
    it "returns an element hash" do
      expect(described_class.read(xml)).to contain_exactly(character)
    end
  end
end
