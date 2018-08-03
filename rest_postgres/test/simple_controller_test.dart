import 'harness/app.dart';

Future main() async {
  Harness app = Harness()..install();

  tearDown(() async {
    await app.resetData();
  });

  group("Success flow", () {
    test("Can create model", () async {
      var response = await app.agent.post("/_model", body: {"name": "Bob"});

      expect(response, hasResponse(200, body: {
        "id": isNotNull,
        "name": "Bob",
        "createdAt": isTimestamp
      }));
    });

    test("Can get model", () async {
      var response = await app.agent.post("/_model", body: {"name": "Bob"});
      Map<String, dynamic> model = response.body.as();

      response = await app.agent.get("/_model/${model["id"]}");
      expect(response, hasResponse(200, body: {
        "id": model["id"],
        "name": model["name"],
        "createdAt": model["createdAt"]
      }));
    });
  });
}
