require 'spec_helper'

describe "*** Query methods (based on spec/genealogy/sample_pedigree*.pdf files) *** ", :done, :query, :wip do

  before { @model = get_test_model({current_spouse: true})}
  include_context "pedigree exists"

  describe "class methods" do
    describe ".males" do
      specify do
        all_males = [ruben, paul, peter, paso, manuel, john, jack, bob, tommy, luis, larry, ned, steve, marcel, julian, rud, mark, sam, charlie]
        expect(@model.males.all).to match_array all_males
      end
    end
    describe ".females" do
      specify do
        all_females = [titty, mary, barbara, irene, terry, debby, alison, maggie, emily, rosa, louise, naomi, michelle, beatrix, mia, sue]
        expect(@model.females.all).to match_array all_females
      end
    end
    describe ".all_with" do
      context 'with argument :father' do
        specify { expect(@model.all_with(:father)).to match_array [irene, beatrix, julian, mary, peter, ruben, steve, mark, rud, titty, michelle, charlie, sam, sue, terry, paul, emily, tommy, barbara, john, paso, debby, jack] }
      end
      context 'with argument :mother' do
        specify { expect(@model.all_with(:mother)).to match_array [john, paso, mary, irene, mark, rud, titty, debby, jack, tommy, barbara, charlie, sam, sue, beatrix, julian, michelle, emily, paul, peter, steve] }
      end
      context 'with argument :parents' do
        specify { expect(@model.all_with(:parents)).to match_array [john, paso, mary, irene, mark, rud, titty, debby, jack, tommy, barbara, charlie, sam, sue, beatrix, julian, michelle, emily, paul, peter, steve] }
      end
    end
  end

  describe "peter" do
    subject {peter}
    context "if he hadn't parents" do
      before { peter.remove_parents }
      its(:parents) { is_expected.to match_array [nil, nil]}
      its(:paternal_grandfather) {is_expected.to be_nil}
      its(:paternal_grandmother) {is_expected.to be_nil}
      its(:maternal_grandfather) {is_expected.to be_nil}
      its(:maternal_grandmother) {is_expected.to be_nil}
      its(:grandparents) {is_expected.to match_array [nil, nil, nil, nil]}
      its(:siblings) {is_expected.to be_empty}
      its(:paternal_grandparents) {is_expected.to match_array [nil, nil]}
      its(:maternal_grandparents) {is_expected.to match_array [nil, nil]}
      its(:half_siblings) {is_expected.to be_empty}
      its(:ancestors) {is_expected.to be_empty}
      its(:uncles) {is_expected.to be_empty}
      its(:maternal_uncles) {is_expected.to be_empty}
      its(:paternal_uncles) {is_expected.to be_empty}
      its(:great_grandparents) {is_expected.to match_array [nil, nil, nil, nil, nil, nil, nil, nil]}
      its(:family) {is_expected.to be_empty}
    end
    its(:parents) { is_expected.to match_array [paul, titty]}
    its(:paternal_grandfather) {is_expected.to eq manuel}
    its(:paternal_grandmother) {is_expected.to eq terry}
    its(:maternal_grandfather) {is_expected.to eq paso}
    its(:maternal_grandmother) {is_expected.to eq irene}
    its(:grandparents) {is_expected.to match_array [manuel, terry, paso, irene]}
    its(:siblings) {is_expected.to match_array [steve]}
    its(:paternal_grandparents) {is_expected.to match_array [manuel, terry]}
    its(:maternal_grandparents) {is_expected.to match_array [paso, irene]}
    its(:half_siblings) {is_expected.to match_array [ruben, mary, julian, beatrix]}
    its(:uncles) {is_expected.to match_array [mark, rud]}
    its(:maternal_uncles) {is_expected.to match_array [mark, rud]}
    its(:paternal_uncles) {is_expected.to be_empty}
    its(:great_grandparents) {is_expected.to match_array [nil, nil, marcel, nil, jack, alison, tommy, emily]}
    describe "ancestors" do
      it {expect(peter.ancestors).to match_array([paul, titty, manuel, terry, paso, irene, tommy, emily, larry, louise, luis, rosa, marcel, bob, jack, alison])}
      context "with options generations: 0" do
        specify { expect(peter.ancestors(generations: 0)).to  match_array([])}
      end
      context "with options generations: 1" do
        specify { expect(peter.ancestors(generations: 1)).to  match_array([paul, titty])}
      end
      context "with options generations: 2" do
        specify { expect(peter.ancestors(generations: 2)).to  match_array([paul, titty, manuel, terry, paso, irene])}
      end
      context "with wrong options generations: 'foo'" do
        specify { expect { peter.ancestors(generations: 'foo') }.to raise_error(ArgumentError) }
      end
    end
    describe "cousins" do
      it { expect(peter.cousins).to match_array([sam, charlie, sue])}
      context "with options lineage: :paternal" do
        specify { expect(peter.cousins(lineage: :paternal)).to  be_empty }
      end
      context "with options lineage: :maternal" do
        specify { expect(peter.cousins(lineage: :maternal)).to  match_array [sam,charlie,sue] }
      end
    end
    describe "family_hash" do
      it { expect( peter.family_hash ).to match_family({father: paul, mother: titty, children: [], siblings: [steve], :current_spouse=>nil}) }
      context "with options half: :include" do
        specify { expect(peter.family_hash(half: :include)).to match_family({father: paul, mother: titty, children: [], siblings: [steve], :current_spouse=>nil, half_siblings: [ruben, mary, julian, beatrix] })}
      end
      context "with options half: :include_separately" do
        specify { expect(peter.family_hash(half: :include_separately)).to match_family({father: paul, mother: titty, children: [], siblings: [steve], :current_spouse=>nil, paternal_half_siblings: [ruben, mary, julian, beatrix], maternal_half_siblings: [] })}
        context 'and singular_role: true' do
          specify { expect(peter.family_hash(singular_role: true, half: :include_separately)).to match_family(
            father: paul,
            mother: titty,
            daughter: [],
            son: [],
            brother: [steve],
            sister: [],
            current_spouse: nil,
            paternal_half_brother: [ruben, julian],
            paternal_half_sister: [mary, beatrix],
            maternal_half_brother: [],
            maternal_half_sister: []
          )}
        end
      end
      context "with options half: :father" do
        specify { expect(peter.family_hash(half: :father)).to match_family({father: paul, mother: titty, children: [], siblings: [steve], :current_spouse=>nil, paternal_half_siblings: [ruben, mary, julian, beatrix] })}
      end
      context "with options half: :mother" do
        specify { expect(peter.family_hash(half: :mother)).to match_family({father: paul, mother: titty, children: [], siblings: [steve], :current_spouse=>nil, maternal_half_siblings: [] })}
      end
      context "with options extended: true" do
        specify { expect(peter.family_hash(extended: true)).to match_family(
          :father=>paul,
          :mother=>titty,
          :children=>[],
          :siblings=>[steve],
          :current_spouse=>nil,
          :paternal_grandfather=>manuel,
          :paternal_grandmother=>terry,
          :maternal_grandfather=>paso,
          :maternal_grandmother=>irene,
          :grandchildren=>[],
          :uncles_and_aunts=>[rud, mark],
          :nieces_and_nephews=>[],
          :cousins=>[sam, sue, charlie])}
      end
      context "with options extended: true, half: :include" do
        specify { expect(peter.family_hash(extended: true, half: :include)).to match_family(
          :father=>paul,
          :mother=>titty,
          :children=>[],
          :siblings=>[steve],
          :current_spouse=>nil,
          :paternal_grandfather=>manuel,
          :paternal_grandmother=>terry,
          :maternal_grandfather=>paso,
          :maternal_grandmother=>irene,
          :grandchildren=>[],
          :uncles_and_aunts=>[rud, mark],
          :nieces_and_nephews=>[],
          :cousins=>[sam, sue, charlie],
          :half_siblings=>[ruben, mary, julian, beatrix])}
      end
      context "with options half: :bar" do
        specify { expect { peter.family_hash(half: :bar) }.to raise_error(ArgumentError)}
      end
    end
    describe "family" do
      it { expect(peter.family).to match_array([paul, titty, steve])}
      context "with options half: :include" do
        specify { expect(peter.family(half: :include)).to match_array([paul, titty, steve, ruben, mary, julian, beatrix])}
      end
      context "with options half: :father" do
        specify { expect(peter.family(half: :father)).to match_array([paul, titty, steve, ruben, mary, julian, beatrix])}
      end
      context "with options half: :mother" do
        specify { expect(peter.family(half: :mother)).to match_array([paul, titty, steve])}
      end
      context "with options extended: true" do
        specify { expect(peter.family(extended: true)).to match_array([paul, titty, steve, manuel, terry, paso, irene, rud, mark, sue, sam, charlie])}
      end
      context "with options extended: true, half: :include" do
        specify { expect(peter.family(extended: true, half: :include)).to match_array([paul, titty, steve, manuel, terry, paso, irene, rud, mark, sue, sam, charlie, ruben, mary, julian, beatrix])}
      end
      context "with options half: :bar" do
        specify { expect { peter.family(half: :bar) }.to raise_error(ArgumentError)}
      end
    end
  end

  describe "mary" do
    subject {mary}
    its(:parents) {is_expected.to match_array [paul, barbara]}
    its(:paternal_grandfather) {is_expected.to eq manuel}
    its(:paternal_grandmother) {is_expected.to eq terry}
    its(:maternal_grandfather) {is_expected.to eq john}
    its(:maternal_grandmother) {is_expected.to eq maggie}
    its(:paternal_grandparents) {is_expected.to match_array [manuel, terry]}
    its(:maternal_grandparents) {is_expected.to match_array [john, maggie]}
    its(:grandparents) {is_expected.to match_array [manuel, terry, john, maggie]}
    its(:half_siblings) {is_expected.to match_array [ruben, peter, julian, beatrix, steve] }
    its(:descendants) {is_expected.to be_empty}
    its(:siblings) {is_expected.to be_empty }
    its(:ancestors) {is_expected.to match_array [paul, barbara, manuel, terry, john, maggie, marcel, jack, alison, bob, louise]}
  end

  describe "beatrix" do
    subject {beatrix}
    its(:parents) {is_expected.to match_array [paul, michelle]}
    its(:siblings) {is_expected.to match_array [julian]}
    its(:half_siblings) {is_expected.to match_array [ruben, peter, steve, mary]}
    its(:paternal_half_siblings) {is_expected.to match_array [ruben, peter, steve, mary]}
    describe "all half_siblings and siblings: #siblings(half: :include)" do
      specify {expect(beatrix.siblings(half: :include)).to match_array [ruben, peter, steve, mary, julian]}
    end
    describe "half_siblings with titty: #siblings(half: father, spouse: titty)" do
      specify {expect(beatrix.siblings(half: :father, spouse: titty)).to match_array [peter, steve]}
    end
    describe "half_siblings with mary: #siblings(half: father, spouse: barbara)" do
      specify {expect(beatrix.siblings(half: :father, spouse: barbara)).to match_array [mary]}
    end
  end

  describe "paul" do
    subject {paul}
    its(:spouses) {is_expected.to match_array [michelle,titty,barbara]}
    its(:parents) {is_expected.to match_array [manuel, terry]}
    describe "children" do
      it { expect(paul.children).to match_array([ruben, peter, mary, julian, beatrix, steve])}
      context "with options spouse: barbara" do
        specify { expect(paul.children(spouse: barbara)).to match_array [mary] }
      end
      context "with options spouse: michelle" do
        specify { expect(paul.children(spouse: michelle)).to match_array [julian, beatrix] }
      end
      context "with options spouse: nil" do
        specify { expect { paul.children(spouse: nil) }.to raise_error ArgumentError}
      end
    end
    its(:ancestors) {is_expected.to match_array [manuel, terry, marcel]}
    its(:descendants) {is_expected.to match_array [ruben, peter, mary, julian, beatrix, steve]}
    its(:maternal_grandmother) {is_expected.to be_nil}
    its(:maternal_grandparents) {is_expected.to match_array [marcel, nil]}
    its(:grandparents) {is_expected.to match_array [nil, nil, marcel, nil]}
  end

  describe "terry" do
    subject {terry}
    its(:father) {is_expected.to eq marcel}
    its(:mother) {is_expected.to be_nil}
    its(:parents) {is_expected.to match_array [marcel, nil]}
    its(:ancestors) {is_expected.to match_array [marcel]}
    its(:grandchildren) {is_expected.to match_array [ruben, julian,beatrix,peter,steve,mary]}
  end

  describe "barbara" do
    subject {barbara}
    its(:children) {is_expected.to match_array [mary]}
    describe "children with manuel" do
      specify { expect(barbara.children(spouse: manuel)).to be_empty }
    end
    its(:descendants) {is_expected.to match_array [mary]}
    its(:grandparents) {is_expected.to match_array [jack, alison, nil, nil]}
    describe "cousins" do
      it { expect(barbara.cousins).to match_array([titty,rud,mark])}
      context "with options lineage: :paternal" do
        specify { expect(barbara.cousins(lineage: :paternal)).to  match_array [titty,rud,mark] }
      end
      context "with options lineage: :maternal" do
        specify { expect(barbara.cousins(lineage: :maternal)).to  be_empty }
      end
    end
  end

  describe "paso" do
    subject {paso}
    its(:children) {is_expected.to match_array [titty, rud, mark]}
    its(:descendants) {is_expected.to match_array [titty, peter, steve, rud, mark, sam, charlie, sue]}
    its(:aunts) {is_expected.to match_array [debby]}
    its(:maternal_aunts) {is_expected.to be_empty}
    its(:paternal_aunts) {is_expected.to match_array [debby]}
    describe "family_hash" do
      it { expect( paso.family_hash ).to match_family({
        father: jack,
        mother: alison,
        children: [titty,rud,mark],
        siblings: [john],
        current_spouse: irene}) }
      context "with options half: :include" do
        specify { expect(paso.family_hash(half: :include)).to match_family({
          father: jack,
          mother: alison,
          children: [titty,rud,mark],
          siblings: [john],
          current_spouse: irene,
          half_siblings: [] })}
      end
      context "with options extended: true" do
        specify { expect(paso.family_hash(extended: true)).to match_family(
          father: jack,
          mother: alison,
          children: [titty,rud,mark],
          siblings: [john],
          current_spouse: irene,
          :paternal_grandfather=>bob,
          :paternal_grandmother=>louise,
          :maternal_grandfather=>nil,
          :maternal_grandmother=>nil,
          :grandchildren=>[peter,steve,sue,sam,charlie],
          :uncles_and_aunts=>[debby],
          :nieces_and_nephews=>[],
          :cousins=>[])}
      end
    end

  end

  describe "louise" do
    subject {louise}
    describe "children" do
      specify { expect(louise.children).to match_array [tommy, jack, debby] }
      context 'with option spouse: bob' do
        specify { expect(louise.children(spouse: bob)).to match_array [jack, debby] }
      end
      context 'with option spouse: larry' do
        specify { expect(louise.children(spouse: larry)).to match_array [tommy] }
      end
    end
    describe "descendants" do
      specify { expect(louise.descendants).to match_array [tommy, irene, titty, peter, jack, john, barbara, mary, debby, steve, paso, rud, mark, sam, charlie, sue] }
      context 'with option generations: 0' do
        specify { expect(louise.descendants(generations: 0)).to match_array []  }
      end
      context 'with option generations: 1' do
        specify { expect(louise.descendants(generations: 1)).to match_array [tommy, jack, debby]  }
      end
      context 'with option generations: 2' do
        specify { expect(louise.descendants(generations: 2)).to match_array [tommy, jack, debby, irene, john, paso]  }
      end
    end
    its(:ancestors) {is_expected.to be_empty}
    its(:great_grandchildren) {is_expected.to match_array [titty, rud, mark, barbara]}
    its(:great_grandparents) {is_expected.to match_array [nil, nil, nil, nil, nil, nil, nil, nil]}
    its(:father){is_expected.to be_nil}
    its(:parents){is_expected.to match_array [nil,nil]}
    its(:spouses) {is_expected.to match_array [larry,bob]}
  end

  describe "michelle" do
    subject { michelle }
    its(:family) {is_expected.to match_array [naomi,julian,beatrix,paul,ned] }
    its(:extended_family) {is_expected.to match_array [naomi,julian,beatrix,paul,ned] }
  end

  describe "titty" do
    subject { titty }
    its(:uncles_and_aunts) {is_expected.to match_array [john] }
    its(:uncles) {is_expected.to match_array [john] }
    its(:paternal_uncles) {is_expected.to match_array [john] }
    its(:maternal_uncles) {is_expected.to be_empty }
    its(:nieces_and_nephews) {is_expected.to match_array [sam,charlie,sue]}
    its(:nephews) {is_expected.to match_array [sam, charlie]}
    its(:nieces) {is_expected.to match_array [sue]}
    describe "cousins" do
      it { expect(titty.cousins).to match_array([barbara])}
      context "with options lineage: :paternal" do
        specify { expect(titty.cousins(lineage: :paternal)).to  match_array [barbara] }
      end
      context "with options lineage: :maternal" do
        specify { expect(titty.cousins(lineage: :maternal)).to  be_empty }
      end
    end
    its(:family) {is_expected.to match_array [peter,steve,rud,mark,irene,paso]}
    its(:extended_family) {is_expected.to match_array [peter,steve,rud,mark,irene,paso,sam,charlie,emily,sue,tommy,jack,alison,john, barbara]}
    describe "family_hash" do
      it { expect( titty.family_hash ).to match_family({
        father: paso,
        mother: irene,
        children: [peter,steve],
        siblings: [rud,mark],
        current_spouse: nil}) }
      context "with options extended: true" do
        specify { expect(titty.family_hash(extended: true)).to match_family(
          father: paso,
          mother: irene,
          children: [peter,steve],
          siblings: [rud,mark],
          current_spouse: nil,
          :paternal_grandfather=>tommy,
          :paternal_grandmother=>emily,
          :maternal_grandfather=>jack,
          :maternal_grandmother=>alison,
          :grandchildren=>[],
          :uncles_and_aunts=>[john],
          :nieces_and_nephews=>[sue,sam,charlie],
          :cousins=>[barbara])}
        context 'and singular_role: true' do
          specify { expect(titty.family_hash(extended: true, singular_role: true)).to match_family(
            father: paso,
            mother: irene,
            daughter: [],
            son: [peter,steve],
            brother: [rud,mark],
            sister: [],
            current_spouse: nil,
            paternal_grandfather: tommy,
            paternal_grandmother: emily,
            maternal_grandfather: jack,
            maternal_grandmother: alison,
            grandchild: [],
            uncle: [john],
            aunts: [],
            niece: [sue],
            nephew: [sam,charlie],
            cousin: [barbara]
          )}

        end
      end
      context 'with options singular_role: true' do
        specify { expect(titty.family_hash(singular_role: true)).to match_family(
          father: paso,
          mother: irene,
          daughter: [],
          son: [peter,steve],
          brother: [rud,mark],
          sister: [],
          current_spouse: nil
        )}
      end
    end

  end

  describe "irene" do
    subject { irene }
    its(:uncles_and_aunts) {is_expected.to be_empty }
    describe "#uncles_and_aunts(half: :include)" do
      specify { expect(irene.uncles_and_aunts(half: :include)).to match_array [debby, jack] }
    end
    describe "#uncles_and_aunts(half: :include, lineage: :paternal )" do
      specify { expect(irene.uncles_and_aunts(half: :include, lineage: :paternal )).to match_array [debby, jack] }
    end
  end

  describe "rud" do
    subject { rud }
    its(:nieces_and_nephews) {is_expected.to match_array [sue, sam, charlie, peter, steve] }
  end

  describe "tommy" do
    subject { tommy }
    its(:nieces_and_nephews) {is_expected.to be_empty }
    describe "#nieces_and_nephews({},{half: :include })" do
      specify { expect(tommy.nieces_and_nephews({half: :include })).to match_array [paso, john] }
    end
  end

end
