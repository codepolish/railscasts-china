require 'spec_helper'

describe Episode do
  subject { create(:episode) }
  it { should belong_to(:user)}
  it { should validate_presence_of :name }
  it { should validate_presence_of :permalink }
  it { should validate_presence_of :description }
  it { should validate_presence_of :notes }

  describe "Scope" do
    describe ".by_tag" do
      before do
        @episode1 = create(:episode)
        @episode2 = create(:episode)
        @episode1.tags << Tag.create(name: "activerecord")
        @episode2.tags << Tag.create(name: "activemodel")
      end

      it "should filter the episode by tag_name" do
        Episode.by_tag('activemodel').to_a.should == [@episode2]
      end

      it "should return all records if tag_name is nil" do
        Episode.by_tag(nil).count.should == 2
      end
    end

    describe ".by_keywords" do
      let!(:episode) { create(:episode, name: 'this is superman la' )}
      let!(:episode2) { create(:episode, name: 'is that irronman') }
      let!(:episode3) { create(:episode, name: 'xman') }


      context "one keyword" do
        let(:query) { "superman" }
        specify { Episode.by_keywords(query).count.should == 1 }
        specify { Episode.by_keywords(query).should include(episode) }
      end

      context "two keywords" do
        let(:query) { "superman irronman"}
        specify { Episode.by_keywords(query).count.should == 2 }
        specify { Episode.by_keywords(query).should include(episode) }
        specify { Episode.by_keywords(query).should include(episode2) }
      end

      context "blank query" do
        let(:query) { "" }
        specify { Episode.by_keywords(query).count.should == 3 }
      end

      context "ignore cases" do
        let(:query) { "IrrOnMaN" }
        specify { Episode.by_keywords(query).count.should == 1 }
        specify { Episode.by_keywords(query).should include(episode2) }
      end
    end
  end

  describe "Instance Method" do
    let(:episode) { create(:episode, permalink: 13466, seconds: 600) }

    describe "#to_param" do
      it "should a string" do
        episode.to_param.should be_instance_of String
      end

      it "should return the permalink" do
        episode.to_param.should == "13466"
      end
    end

    describe "#minutes" do
      it "should return the minutes of a episode" do
        episode.minutes.should == 10
      end
    end

    describe "#tags" do
      it "should create Tag" do
        expect do
          episode.tag_list = "new"
        end.to change(Tag, :count).by(1)
      end

      it "should spilt the tag string" do
        tags_string = "activerecord, 3.0"
        episode.tag_list = tags_string
        episode.tags.collect(&:name).include?('activerecord').should be_true
        episode.tags.collect(&:name).include?('3.0').should be_true
      end

      it "should not duplicate the tags" do
        tags_string = "activerecord, activerecord"
        episode.tag_list = tags_string
        episode.tags.size.should == 1
      end

      it "should get the tag list" do
        episode.tags << Tag.create(name: "test")
        episode.tags << Tag.create(name: "rspec")
        episode.tag_list.should == "test, rspec"
      end
    end

    describe "#duration" do
      let(:episode1) { create(:episode, seconds: 35)}
      let(:episode2) { create(:episode, seconds: 700)}

      it { episode1.duration.should == "0:35" }
      it { episode2.duration.should == "11:40" }
    end


    describe "#set_position" do
      attr_reader :episode
      before do
        @episode = FactoryGirl.create(:episode)
      end

      subject { episode }

      its(:position) { should == 1 }

      it {
        episode.update_attributes(name: "Test")
        episode.position.should == 1
      }

      it {
        new_episode = FactoryGirl.create(:episode)
        new_episode.position.should == 2
      }


    end

  end
end
