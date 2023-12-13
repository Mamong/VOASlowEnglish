//REST风格
class RestUrlBuilder {

  static const String _baseUrl = '';

  static Function buildGetQuoteUrl = (int id) => '$_baseUrl/quotes/$id';

}