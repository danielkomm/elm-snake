# 7. Übung zur Vorlesung Deklarative Software-Technologien


## Aufgabe 1 - Bewertung der Veranstaltung

Führen Sie die Online-Evaluation der Veranstaltung durch.
Sie sollten zu diesem Zweck eine Mail erhalten haben.
Falls Sie keine Mail erhalten haben, melden Sie sich bitte.
Bitte nehmen Sie sich ausreichend Zeit für die Bewertung der Veranstaltung.


## Aufgabe 2 - Highscores

In dieser Aufgabe sollen Sie Ihre Snake-Anwendung um die Anzeige von Highscores erweitern.
Diese Highscores sollen von der URL `http://193.175.181.175/highscores` geladen werden.
Der entsprechende Server steht nur im lokalen Netz der Hochschule zur Verfügung.
Eine Dokumentation der Schnittstelle finden Sie unter `http://193.175.181.175/docs`.
Die Anwendung soll immer, wenn eine Runde beendet ist, die Liste der Highscores anzeigen.

  - Erweitern Sie Ihre Anwendung um eine Punktzahl.
    Die Punktzahl soll erhöht werden, wenn die Schlange Futter frisst.

  - Nutzen Sie den folgenden Datentyp zur Darstellung eines Highscore.

    ```elm
    type alias Highscore = { player : String, score : Int }
    ```

    Definieren Sie einen `Decoder`, um einen Wert vom Typ `Highscore` aus einer JSON-Antwort der Schnittstelle zu extrahieren.

  - Bauen Sie die oben beschriebene Funktionalität in Ihre Anwendung ein.
    Nutzen Sie den Datentyp `Data`, um abzubilden, dass die Anwendung auf Informationen wartet bzw. dass die Anfrage fehlgeschlagen ist.
    Zeigen Sie die Fälle des Datentyps `Http.Error` in sinnvoller Weise für den Nutzer an.
    Informieren Sie den Nutzer, falls auf dem Server bisher noch keine Highscores eingetragen sind.


## Aufgabe 3 (Optional) - Konstruktion von komplexen Decodern

Um aus mehreren "einfachen" Decodern einen komplexeren Decoder zu konstruieren, verwenden wir bisher die Funktion `map2`.
Elm stellt neben `map2` noch Funktionen `map3`, `map4` bis `map8` zur Verfügung, bei denen die Zahl jeweils angibt, wie viele Decoder mit der Funktion kombiniert werden können.
Dieser Ansatz hat den Nachteil, dass Elm zum einen sehr viele verschiedene Funktionen zur Verfügung stellen muss.
Außerdem können wir mit diesem Ansatz nur maximal acht Decoder zu einem neuen Decoder kombinieren.
Elm setzt trotz dieser Nachteile auf diesen Ansatz, da er vergleichsweise einfach und damit einsteigerfreundlich ist.
Wir wollen uns daher an dieser Stelle eine alternative Technik anschauen, welche diese Nachteile nicht mit sich bringt.

  - Definieren Sie eine Funktion `apply : Decoder (a -> b) -> Decoder a -> Decoder b`.
    Diese Funktion erzeugt einen neuen `Decoder`, indem Sie die `Decoder` in den beiden Argumenten ausgeführt.
    Außerdem wird das Ergebnis des ersten `Decoder` auf das Ergebnis des zweiten `Decoder` angewendet.

    **Hinweis:** Sie können `apply` mit Hilfe der Funktionen aus dem Modul `Json.Decode` implementieren, die Sie aus der Vorlesung kennen.

  - Definieren Sie den `Decoder` für `Highscore`, indem Sie die Funktion `apply` nutzen.

    **Hinweise:** Nutzen Sie in der Definition die partielle Applikation `Decode.succeed Highscore`.
    Schauen Sie sich den Typ von `Decode.succeed` an.
    Überlegen Sie sich dann den Typ von `Decode.succeed Highscore`.
    Überlegen Sie sich nun den Typ von `apply (Decoder.succeed Highscore)`.

  - Mithilfe von `apply` können wir zwar `Decoder` definieren, aufgrund der Schachtelung im ersten Argument von `apply` lässt sich die Definition aber recht schlecht lesen.
    Ändern Sie daher zuerst den Typ von `apply` zu `Decoder a -> Decoder (a -> b) -> Decoder b` ab.
    Passen Sie die Definition ihres `Decoder`s entsprechend an.

  - Nutzen Sie zu guter Letzt die Funktion `|>` in der Definition ihres `Decoder`s, um die Reihenfolge in der Konstruktion umzudrehen.
    Genauer gesagt, sollen Sie die Funktion `apply` jeweils auf ihr erstes Argument partiell applizieren.
    Nutzen Sie dann `|>`, um jeweils das zweite Argument an diese partielle Applikation zu übergeben.
