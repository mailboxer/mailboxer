require "spec_helper"

describe UsersController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/users" }.should route_to(:controller => "users", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/users/new" }.should route_to(:controller => "users", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/users/1" }.should route_to(:controller => "users", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/users/1/edit" }.should route_to(:controller => "users", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/users" }.should route_to(:controller => "users", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/users/1" }.should route_to(:controller => "users", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/users/1" }.should route_to(:controller => "users", :action => "destroy", :id => "1")
    end

  end
end
