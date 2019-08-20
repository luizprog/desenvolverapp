
library dart.Matematica;

String _getPorcentagem(int numAtividades, int pontosAtual) {
    var x = (numAtividades * 100) - pontosAtual;
    var y = (x / pontosAtual) * 100;

    if (y < 0) {
      y = y * (-1);
    }

    var porcentagemFinal = 100 - y.round();

    return porcentagemFinal.toString();
  }
