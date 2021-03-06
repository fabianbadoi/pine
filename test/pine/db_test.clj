(ns pine.db-test
  (:require [clojure.test :refer :all]
            [pine.db :as db]
            [pine.fixtures :as fixtures]
            ))

(deftest references:test-schema
  (testing "Get the references of a table"
    (is
     (=
      {:users "userId"
       :customers "customerId"
       }
      (db/references fixtures/schema "caseFiles")
      ))))


(deftest relation:test-schema-owns
  (testing "Get the references of a table"
    (is
     (=
      "caseFileId"
      (db/relation fixtures/schema :caseFiles :owns :documents))
     )))

(deftest relation:test-schema-owned-by
  (testing "Get the references of a table"
    (is
     (=
      "caseFileId"
      (db/relation fixtures/schema :documents :owned-by :caseFiles))
     )))
