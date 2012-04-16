require 'init_tests'
require 'rails-canhaz'
require 'test/unit'
require 'models/object_model'
require 'models/subject_model'
require 'models/foo_model'

load 'schema.rb'

class CanHazTest < Test::Unit::TestCase

  def test_methods
    assert ActiveRecord::Base.respond_to? :acts_as_canhaz_object
    assert ActiveRecord::Base.respond_to? :acts_as_canhaz_subject


    foo = FooModel.new

    assert foo.canhaz_object? == false
    assert foo.canhaz_subject? == false

    object = ObjectModel.new

    assert object.canhaz_object?
    assert object.canhaz_subject? == false

    subject = SubjectModel.new

    assert subject.canhaz_subject?
    assert subject.canhaz_object? == false

  end

  def test_exceptions
    foo = FooModel.new

    subject = SubjectModel.new

    object = ObjectModel.new

    assert_raise CanHaz::Exceptions::NotACanHazObject do
        subject.can(:whatever, foo)
    end

    assert_nothing_raised RuntimeError do
        subject.can(:whatever, object)
    end

    assert_raise CanHaz::Exceptions::NotACanHazObject do
        subject.can?(:whatever, foo)
    end

    assert_nothing_raised RuntimeError do
        subject.can?(:whatever, object)
    end

  end

  def test_can
    subject = SubjectModel.new
    subject.save

    object = ObjectModel.new
    object.save

    assert subject.can?(:foo, object) == false
    assert subject.can?(:bar, object) == false

    assert object.accessible_by?(subject, :foo) == false
    assert object.accessible_by?(subject, :bar) == false

    assert subject.can(:foo, object)
    assert subject.can(:bar, object)

    assert subject.can(:foo, object) == false
    assert subject.can(:bar, object) == false

    assert subject.can?(:foo, object)
    assert subject.can?(:bar, object)

    assert object.accessible_by?(subject, :foo)
    assert object.accessible_by?(subject, :bar)

    assert subject.objects_with_permission(ObjectModel, :foo).count == 1
    assert subject.objects_with_permission(ObjectModel, :foo).first == object

    assert subject.objects_with_permission(ObjectModel, :bar).count == 1
    assert subject.objects_with_permission(ObjectModel, :bar).first == object

    assert subject.objects_with_permission(ObjectModel, :foobar).count == 0

  end

  def test_can_cannot
    subject = SubjectModel.new
    subject.save

    object = ObjectModel.new
    object.save

    assert subject.can?(:foo, object) == false
    assert subject.cannot(:foo, object) == false

    subject.can(:foo, object)
    subject.can(:bar, object)

    assert subject.can?(:foo, object)
    assert subject.can?(:bar, object)

    assert subject.cannot(:foo, object) == true

    assert subject.can?(:foo, object) == false
    assert subject.can?(:bar, object) == true
  end

end

