require 'spec_helper'

describe 'TestModel', :model do

  subject { @model }

  opts1 = {column_names: {father_id: "padre", mother_id: "madre", sex: "gender", birth_date: "dob", death_date: "dod"}}
  context "initialized with options: #{opts1}"  do
    before(:context) { @model = get_test_model(opts1) }
    opts1[:column_names].each do |attribute,col_name|
      class_attribute = "#{attribute}_column"
      its(class_attribute) { is_expected.to eq col_name }
      it "has db column named #{col_name}" do
        expect(@model.column_names).to include(col_name)
      end
    end
    its(:sex_male_value) { is_expected.to eq 'M' }
    its(:sex_female_value) { is_expected.to eq 'F' }
    its(:current_spouse_enabled) { is_expected.to be false }
    its(:perform_validation_enabled) { is_expected.to be true }
  end

  opts2 = {column_names: {sex: "gender"}, sex_values: [1,2]}
  context "initialized with options: #{opts2}"  do
    before(:context) { @model = get_test_model(opts2) }
    its(:sex_column) { is_expected.to eq 'gender'}
    its(:sex_values) { is_expected.to be_a_kind_of(Array)}
    its(:sex_male_value) { is_expected.to eq 1}
    its(:sex_female_value) { is_expected.to eq 2}
  end

  opts3 = {sex_values: [:male,:female]}
  context "initialized with options: #{opts3}"  do
    before(:context) { @model = get_test_model(opts3) }
    its(:sex_column) { is_expected.to eq 'sex'}
    its(:sex_values) { is_expected.to be_a_kind_of(Array)}
    its(:sex_male_value) { is_expected.to eq :male}
    its(:sex_female_value) { is_expected.to eq :female}
  end

  opts4 = {sex_values: ['male','female']}
  context "initialized with options: #{opts4}"  do
    before(:context) { @model = get_test_model(opts4) }
    its(:sex_column) { is_expected.to eq 'sex'}
    its(:sex_values) { is_expected.to be_a_kind_of(Array)}
    its(:sex_male_value) { is_expected.to eq 'male'}
    its(:sex_female_value) { is_expected.to eq 'female'}
  end

  opts5 = {column_names: {current_spouse_id: "partner"}, current_spouse: true}
  context "initialized with options: #{opts5}"  do
    before(:context) { @model = get_test_model(opts5) }
    its(:current_spouse_id_column) { is_expected.to eq 'partner' }
    its(:column_names) { is_expected.to include("partner") }
    its(:current_spouse_enabled) { is_expected.to be true }
  end

  opts6 = {perform_validation: false}
  context "initialized with options: #{opts6}"  do
    before(:context) { @model = get_test_model(opts6) }
    its(:perform_validation_enabled) { is_expected.to be false }
  end

  context "initialized with default options", wip: true  do
    before(:context) { @model = get_test_model }
    ['father_id', 'mother_id'].each do |col_name|
      class_attribute = "#{col_name}_column"
      its(class_attribute) { is_expected.to eq col_name }
      it "has db column #{col_name}" do
        expect(@model.column_names).to include("#{col_name}")
      end
    end
    its(:gclass) { is_expected.to be @model }
    its(:perform_validation_enabled) { is_expected.to be true }
    its(:column_names) { is_expected.not_to include("current_spouse_id") }
    its(:current_spouse_enabled) { is_expected.to be false }
    its(:ineligibility_level) { is_expected.to be Genealogy::Constants::PEDIGREE }
    [:min_male_procreation_age, :max_male_procreation_age, :min_female_procreation_age, :max_female_procreation_age, :max_male_life_expectancy, :max_female_life_expectancy].each do |age|
      describe age do
        specify { expect { @model.send(age) }.to raise_error NoMethodError}
      end
    end
  end

  opts7 = {column_names: 'bar' }
  context "initialized with wrong options: #{opts7}"  do
    specify { expect { get_test_model(opts7) }.to raise_error ArgumentError }
  end

  opts10 = {ineligibility: :pedigree}
  context "initialized with options: #{opts10}"  do
    before(:context) { @model = get_test_model(opts10) }
    its(:ineligibility_level) { is_expected.to be Genealogy::Constants::PEDIGREE }
  end

  opts11 = {ineligibility: :pedigree_and_dates, limit_ages: {min_male_procreation_age: 12}}
  context "initialized with options: #{opts11}"  do
    before(:context) { @model = get_test_model(opts11) }
    its(:ineligibility_level) { is_expected.to be Genealogy::Constants::PEDIGREE_AND_DATES }
    [:max_male_procreation_age, :min_female_procreation_age, :max_female_procreation_age, :max_male_life_expectancy, :max_female_life_expectancy].each do |age|
      its(age) { is_expected.to eq Genealogy::Constants::DEFAULTS[:limit_ages][age] }
    end
    its(:min_male_procreation_age) { is_expected.to be 12 }
  end

  opts12 = {ineligibility: true }
  context "initialized with options: #{opts12}"  do
    before(:context) { @model = get_test_model(opts12) }
    its(:ineligibility_level) { is_expected.to be Genealogy::Constants::PEDIGREE }
  end

  opts13 = {ineligibility: false}
  context "initialized with options: #{opts13}"  do
    before(:context) { @model = get_test_model(opts13) }
    its(:ineligibility_level) { is_expected.to be Genealogy::Constants::OFF }
  end

  opts14 = {ineligibility: 'foo'}
  context "initialized with options: #{opts14}"  do
    specify { expect { get_test_model(opts14) }.to raise_error ArgumentError }
  end

end

