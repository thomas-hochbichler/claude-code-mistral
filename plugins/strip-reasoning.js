class StripReasoning {
  name = "stripreasoning";

  async transformRequestIn(body) {
    if (body.reasoning) {
      delete body.reasoning;
    }
    return body;
  }

  async transformResponseOut(response) {
    return response;
  }
}

module.exports = StripReasoning;
