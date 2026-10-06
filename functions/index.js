const { setGlobalOptions } = require("firebase-functions");
const { onRequest } = require("firebase-functions/https");
const axios = require("axios");

setGlobalOptions({ maxInstances: 10 });

exports.getNews = onRequest(async (req, res) => {
  try {
    const apiKey = process.env.GNEWS_API_KEY;

    if (!apiKey) {
      return res.status(500).json({
        error: "GNews API key is not configured.",
      });
    }

    const category = req.query.category || "general";
    const lang = req.query.lang || "en";
    const country = req.query.country || "us";
    const max = req.query.max || "10";
    const page = req.query.page || "1";

    const response = await axios.get(
      "https://gnews.io/api/v4/top-headlines",
      {
        params: {
          category,
          lang,
          country,
          max,
          page,
          apikey: apiKey,
        },
      },
    );

    res.status(200).json(response.data);
  } catch (error) {
    console.error("GNews error:", error.message);

    res.status(500).json({
      error: "Failed to load news.",
    });
  }
});