# Change Log

## [v1.1.7](https://github.com/amco/dolly/tree/v1.1.7) (2017-05-02)
[Full Changelog](https://github.com/amco/dolly/compare/v1.1.6...v1.1.7)

**Merged pull requests:**

- Do not allow a request to be instantiated with missing config data [\#134](https://github.com/amco/dolly/pull/134) ([seancookr](https://github.com/seancookr))

## [v1.1.6](https://github.com/amco/dolly/tree/v1.1.6) (2017-04-21)
[Full Changelog](https://github.com/amco/dolly/compare/v1.1.5...v1.1.6)

**Closed issues:**

- Add soft delete method [\#131](https://github.com/amco/dolly/issues/131)
- Add a logger [\#129](https://github.com/amco/dolly/issues/129)

**Merged pull requests:**

- add soft delete support completes \#131 [\#132](https://github.com/amco/dolly/pull/132) ([seancookr](https://github.com/seancookr))

## [v1.1.5](https://github.com/amco/dolly/tree/v1.1.5) (2017-02-22)
[Full Changelog](https://github.com/amco/dolly/compare/v1.1.4...v1.1.5)

**Implemented enhancements:**

- Create an interface to retrieve attachment files [\#100](https://github.com/amco/dolly/issues/100)
- Add Enumberable Methods To Dolly::Collection [\#87](https://github.com/amco/dolly/issues/87)

**Closed issues:**

- Add reload method [\#102](https://github.com/amco/dolly/issues/102)

**Merged pull requests:**

- add a logger for queries [\#130](https://github.com/amco/dolly/pull/130) ([seancookr](https://github.com/seancookr))

## [v1.1.4](https://github.com/amco/dolly/tree/v1.1.4) (2016-09-26)
[Full Changelog](https://github.com/amco/dolly/compare/v1.1.3...v1.1.4)

**Merged pull requests:**

- add stats method [\#122](https://github.com/amco/dolly/pull/122) ([seancookr](https://github.com/seancookr))

## [v1.1.3](https://github.com/amco/dolly/tree/v1.1.3) (2016-09-13)
[Full Changelog](https://github.com/amco/dolly/compare/v1.1.2...v1.1.3)

**Implemented enhancements:**

- Add support for Inline attachments [\#97](https://github.com/amco/dolly/issues/97)

**Fixed bugs:**

- when properties use the same default, they point to the same object in memory [\#90](https://github.com/amco/dolly/issues/90)

**Closed issues:**

- Attachments in couchdb [\#93](https://github.com/amco/dolly/issues/93)

**Merged pull requests:**

- add gitignore [\#120](https://github.com/amco/dolly/pull/120) ([seancookr](https://github.com/seancookr))
- add enumerable to dolly collection completes \#87 [\#119](https://github.com/amco/dolly/pull/119) ([seancookr](https://github.com/seancookr))
- Add test for accessors after reload of document [\#118](https://github.com/amco/dolly/pull/118) ([seancookr](https://github.com/seancookr))
- add reload method completes \#102  [\#117](https://github.com/amco/dolly/pull/117) ([seancookr](https://github.com/seancookr))

## [v1.1.2](https://github.com/amco/dolly/tree/v1.1.2) (2016-06-22)
[Full Changelog](https://github.com/amco/dolly/compare/v1.1.1...v1.1.2)

**Merged pull requests:**

- Merge bulk prop updates into 1.0 [\#115](https://github.com/amco/dolly/pull/115) ([seancookr](https://github.com/seancookr))
- Add bulk properties update [\#114](https://github.com/amco/dolly/pull/114) ([javierg](https://github.com/javierg))

## [v1.1.1](https://github.com/amco/dolly/tree/v1.1.1) (2016-06-21)
[Full Changelog](https://github.com/amco/dolly/compare/v1.1.0...v1.1.1)

**Closed issues:**

- timestamps! class method is adding methods to models that dont call timestamps! [\#108](https://github.com/amco/dolly/issues/108)

**Merged pull requests:**

- make an attach file method that does not save [\#113](https://github.com/amco/dolly/pull/113) ([seancookr](https://github.com/seancookr))

## [v1.1.0](https://github.com/amco/dolly/tree/v1.1.0) (2016-06-06)
[Full Changelog](https://github.com/amco/dolly/compare/1.0.1...v1.1.0)

**Merged pull requests:**

- Revisit timestamps to fix method scope completes \#108 [\#110](https://github.com/amco/dolly/pull/110) ([seancookr](https://github.com/seancookr))

## [1.0.1](https://github.com/amco/dolly/tree/1.0.1) (2016-04-22)
[Full Changelog](https://github.com/amco/dolly/compare/v1.0.1...1.0.1)

## [v1.0.1](https://github.com/amco/dolly/tree/v1.0.1) (2016-04-22)
[Full Changelog](https://github.com/amco/dolly/compare/v1.0.0...v1.0.1)

**Merged pull requests:**

- added lib hash to views [\#107](https://github.com/amco/dolly/pull/107) ([norcal82](https://github.com/norcal82))
- rake task imports .lib files [\#105](https://github.com/amco/dolly/pull/105) ([norcal82](https://github.com/norcal82))
- Add design docs [\#103](https://github.com/amco/dolly/pull/103) ([javierg](https://github.com/javierg))
- Inheretance persist properties into parent object [\#101](https://github.com/amco/dolly/pull/101) ([javierg](https://github.com/javierg))
- Improve documentation [\#89](https://github.com/amco/dolly/pull/89) ([rubenrails](https://github.com/rubenrails))

## [v1.0.0](https://github.com/amco/dolly/tree/v1.0.0) (2015-12-03)
[Full Changelog](https://github.com/amco/dolly/compare/v0.9.0...v1.0.0)

**Implemented enhancements:**

- Add `Valid?` blank method, to be implemented by inherited Document class. [\#70](https://github.com/amco/dolly/issues/70)
- Authentication errors to database not properly caught by Exceptions [\#58](https://github.com/amco/dolly/issues/58)
- Better setter methods [\#54](https://github.com/amco/dolly/issues/54)
- Default Should Populate Attribute Before Save \(maybe?\) [\#38](https://github.com/amco/dolly/issues/38)
- default values don't get saved properly [\#26](https://github.com/amco/dolly/issues/26)

**Fixed bugs:**

- Default properties still not working [\#68](https://github.com/amco/dolly/issues/68)
- Authentication errors to database not properly caught by Exceptions [\#58](https://github.com/amco/dolly/issues/58)

**Closed issues:**

- Remove unused tests [\#56](https://github.com/amco/dolly/issues/56)
- Proper gem description [\#4](https://github.com/amco/dolly/issues/4)

**Merged pull requests:**

- Update bundle lock [\#99](https://github.com/amco/dolly/pull/99) ([javierg](https://github.com/javierg))
- add support for inline attachments completes \#97 [\#98](https://github.com/amco/dolly/pull/98) ([seancookr](https://github.com/seancookr))
- add standalone attachments to dolly documents completes \#93 [\#94](https://github.com/amco/dolly/pull/94) ([seancookr](https://github.com/seancookr))
- when properties use the same default they use the same object in memory completes \#90 [\#92](https://github.com/amco/dolly/pull/92) ([seancookr](https://github.com/seancookr))
- default objects should be their own objects in memory completes \#90 [\#91](https://github.com/amco/dolly/pull/91) ([seancookr](https://github.com/seancookr))
- Run validations on `save` [\#84](https://github.com/amco/dolly/pull/84) ([rubenrails](https://github.com/rubenrails))
- proper gem description Completes \#4 [\#83](https://github.com/amco/dolly/pull/83) ([seancookr](https://github.com/seancookr))
- Change from master branch to numbered branches, \#80 [\#81](https://github.com/amco/dolly/pull/81) ([brlanier](https://github.com/brlanier))
- raise execpetion on save! if valid? returns false completes \#70 [\#79](https://github.com/amco/dolly/pull/79) ([seancookr](https://github.com/seancookr))
- Better setter completes \#68, \#54 [\#78](https://github.com/amco/dolly/pull/78) ([seancookr](https://github.com/seancookr))
- add change log [\#76](https://github.com/amco/dolly/pull/76) ([seancookr](https://github.com/seancookr))
- Capture 400 errors that are not 404 properly [\#74](https://github.com/amco/dolly/pull/74) ([brlanier](https://github.com/brlanier))
- Remove non assertion tests completes \#56 [\#57](https://github.com/amco/dolly/pull/57) ([seancookr](https://github.com/seancookr))
- Fails if no timestamps defined [\#53](https://github.com/amco/dolly/pull/53) ([javierg](https://github.com/javierg))

## [v0.9.0](https://github.com/amco/dolly/tree/v0.9.0) (2015-04-14)
[Full Changelog](https://github.com/amco/dolly/compare/v0.8.1...v0.9.0)

**Merged pull requests:**

- default should populate before save completes \#28 [\#52](https://github.com/amco/dolly/pull/52) ([seancookr](https://github.com/seancookr))

## [v0.8.1](https://github.com/amco/dolly/tree/v0.8.1) (2015-03-09)
[Full Changelog](https://github.com/amco/dolly/compare/v0.8.0...v0.8.1)

**Fixed bugs:**

- read property not working correctly [\#50](https://github.com/amco/dolly/issues/50)

**Merged pull requests:**

- fix read property fixes \#50 [\#51](https://github.com/amco/dolly/pull/51) ([seancookr](https://github.com/seancookr))

## [v0.8.0](https://github.com/amco/dolly/tree/v0.8.0) (2015-02-24)
[Full Changelog](https://github.com/amco/dolly/compare/v0.7.6...v0.8.0)

**Implemented enhancements:**

- Add Persisted? Method [\#37](https://github.com/amco/dolly/issues/37)

**Fixed bugs:**

- Timestamps don't work [\#33](https://github.com/amco/dolly/issues/33)

**Closed issues:**

- Add dolly to travis as it is free for public repos [\#40](https://github.com/amco/dolly/issues/40)

**Merged pull requests:**

- add persisted? method fixes \#37 [\#49](https://github.com/amco/dolly/pull/49) ([seancookr](https://github.com/seancookr))
- Better properties [\#47](https://github.com/amco/dolly/pull/47) ([javierg](https://github.com/javierg))
- Add basic travis testing support [\#43](https://github.com/amco/dolly/pull/43) ([brlanier](https://github.com/brlanier))
- add flat\_map to dolly collection [\#42](https://github.com/amco/dolly/pull/42) ([seancookr](https://github.com/seancookr))

## [v0.7.6](https://github.com/amco/dolly/tree/v0.7.6) (2015-01-29)
[Full Changelog](https://github.com/amco/dolly/compare/v0.7.5...v0.7.6)

**Merged pull requests:**

- add timestamps to Dolly::Document [\#46](https://github.com/amco/dolly/pull/46) ([seancookr](https://github.com/seancookr))
- Add update method [\#34](https://github.com/amco/dolly/pull/34) ([javierg](https://github.com/javierg))

## [v0.7.5](https://github.com/amco/dolly/tree/v0.7.5) (2015-01-23)
[Full Changelog](https://github.com/amco/dolly/compare/0.7.5...v0.7.5)

## [0.7.5](https://github.com/amco/dolly/tree/0.7.5) (2015-01-23)
[Full Changelog](https://github.com/amco/dolly/compare/0.7.3...0.7.5)

## [0.7.3](https://github.com/amco/dolly/tree/0.7.3) (2015-01-23)
[Full Changelog](https://github.com/amco/dolly/compare/v0.7.1...0.7.3)

**Implemented enhancements:**

- Date/DateTime Property Support [\#30](https://github.com/amco/dolly/issues/30)
- Add I18n Support [\#27](https://github.com/amco/dolly/issues/27)

**Fixed bugs:**

- Writer Being Called While Accessing Reader [\#36](https://github.com/amco/dolly/issues/36)
- Failing Tests/FakeWeb Passthrough [\#31](https://github.com/amco/dolly/issues/31)

**Closed issues:**

- Add support for multiple types within a Collection [\#44](https://github.com/amco/dolly/issues/44)

**Merged pull requests:**

- Add support for multiple types collections [\#45](https://github.com/amco/dolly/pull/45) ([rubenrails](https://github.com/rubenrails))
- test writer check [\#41](https://github.com/amco/dolly/pull/41) ([yuriy](https://github.com/yuriy))
- Date handling for Dolly [\#32](https://github.com/amco/dolly/pull/32) ([Petercopter](https://github.com/Petercopter))

## [v0.7.1](https://github.com/amco/dolly/tree/v0.7.1) (2014-08-04)
[Full Changelog](https://github.com/amco/dolly/compare/v0.7.0...v0.7.1)

**Merged pull requests:**

- add protocol to config [\#29](https://github.com/amco/dolly/pull/29) ([javierg](https://github.com/javierg))

## [v0.7.0](https://github.com/amco/dolly/tree/v0.7.0) (2014-05-21)
[Full Changelog](https://github.com/amco/dolly/compare/v0.6.2...v0.7.0)

**Merged pull requests:**

- Remove dependency on active model [\#28](https://github.com/amco/dolly/pull/28) ([javierg](https://github.com/javierg))

## [v0.6.2](https://github.com/amco/dolly/tree/v0.6.2) (2014-02-26)
[Full Changelog](https://github.com/amco/dolly/compare/v0.6.1...v0.6.2)

**Merged pull requests:**

- Normalize id on init [\#22](https://github.com/amco/dolly/pull/22) ([javierg](https://github.com/javierg))

## [v0.6.1](https://github.com/amco/dolly/tree/v0.6.1) (2014-02-12)
[Full Changelog](https://github.com/amco/dolly/compare/v0.6.0...v0.6.1)

## [v0.6.0](https://github.com/amco/dolly/tree/v0.6.0) (2014-02-04)
[Full Changelog](https://github.com/amco/dolly/compare/v0.5.7...v0.6.0)

**Merged pull requests:**

- Replace find view with \_all\_docs call [\#20](https://github.com/amco/dolly/pull/20) ([javierg](https://github.com/javierg))

## [v0.5.7](https://github.com/amco/dolly/tree/v0.5.7) (2014-01-10)
[Full Changelog](https://github.com/amco/dolly/compare/v0.5.6...v0.5.7)

## [v0.5.6](https://github.com/amco/dolly/tree/v0.5.6) (2014-01-07)
[Full Changelog](https://github.com/amco/dolly/compare/v0.5.5...v0.5.6)

## [v0.5.5](https://github.com/amco/dolly/tree/v0.5.5) (2013-12-17)
[Full Changelog](https://github.com/amco/dolly/compare/v0.5.4...v0.5.5)

**Merged pull requests:**

- Add authorization on tools method [\#19](https://github.com/amco/dolly/pull/19) ([javierg](https://github.com/javierg))

## [v0.5.4](https://github.com/amco/dolly/tree/v0.5.4) (2013-11-27)
[Full Changelog](https://github.com/amco/dolly/compare/v0.5.3...v0.5.4)

## [v0.5.3](https://github.com/amco/dolly/tree/v0.5.3) (2013-11-22)
[Full Changelog](https://github.com/amco/dolly/compare/v0.5.2...v0.5.3)

## [v0.5.2](https://github.com/amco/dolly/tree/v0.5.2) (2013-11-22)
[Full Changelog](https://github.com/amco/dolly/compare/v0.5.1...v0.5.2)

## [v0.5.1](https://github.com/amco/dolly/tree/v0.5.1) (2013-11-21)
[Full Changelog](https://github.com/amco/dolly/compare/v0.5.0...v0.5.1)

**Merged pull requests:**

- Add id setter [\#18](https://github.com/amco/dolly/pull/18) ([javierg](https://github.com/javierg))

## [v0.5.0](https://github.com/amco/dolly/tree/v0.5.0) (2013-11-19)
[Full Changelog](https://github.com/amco/dolly/compare/v0.4.0...v0.5.0)

**Closed issues:**

- Add https db connection with username and password. [\#3](https://github.com/amco/dolly/issues/3)

**Merged pull requests:**

- Bulk document save [\#17](https://github.com/amco/dolly/pull/17) ([javierg](https://github.com/javierg))
- Add method for handling custom views for a document [\#16](https://github.com/amco/dolly/pull/16) ([javierg](https://github.com/javierg))
- Add hard destroy document method [\#15](https://github.com/amco/dolly/pull/15) ([javierg](https://github.com/javierg))

## [v0.4.0](https://github.com/amco/dolly/tree/v0.4.0) (2013-11-11)
[Full Changelog](https://github.com/amco/dolly/compare/v0.3.0...v0.4.0)

**Merged pull requests:**

- First and last methods [\#14](https://github.com/amco/dolly/pull/14) ([javierg](https://github.com/javierg))

## [v0.3.0](https://github.com/amco/dolly/tree/v0.3.0) (2013-11-08)
[Full Changelog](https://github.com/amco/dolly/compare/v0.2.0...v0.3.0)

**Closed issues:**

- API should be able to create new document [\#2](https://github.com/amco/dolly/issues/2)

**Merged pull requests:**

- Create initializer with properties, fixes \#2 [\#13](https://github.com/amco/dolly/pull/13) ([javierg](https://github.com/javierg))

## [v0.2.0](https://github.com/amco/dolly/tree/v0.2.0) (2013-11-07)
[Full Changelog](https://github.com/amco/dolly/compare/0.2.0...v0.2.0)

## [0.2.0](https://github.com/amco/dolly/tree/0.2.0) (2013-11-07)
[Full Changelog](https://github.com/amco/dolly/compare/v0.1.0...0.2.0)

**Merged pull requests:**

- Config yml support [\#12](https://github.com/amco/dolly/pull/12) ([javierg](https://github.com/javierg))
- Add db:setup task, refactor default couch view [\#11](https://github.com/amco/dolly/pull/11) ([javierg](https://github.com/javierg))

## [v0.1.0](https://github.com/amco/dolly/tree/v0.1.0) (2013-11-05)
**Closed issues:**

- API should be able to update document [\#1](https://github.com/amco/dolly/issues/1)

**Merged pull requests:**

- Document as base class, fixes \#9 [\#10](https://github.com/amco/dolly/pull/10) ([javierg](https://github.com/javierg))
- Add timesamps! class method. [\#6](https://github.com/amco/dolly/pull/6) ([javierg](https://github.com/javierg))
- Handle property class methods [\#5](https://github.com/amco/dolly/pull/5) ([javierg](https://github.com/javierg))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*