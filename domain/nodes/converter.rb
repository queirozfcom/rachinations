require_relative '../../domain/nodes/node'

class Converter < Node

# VEJA O DIAGRAMA BEHAVIOR CONVERTER, inclusive com o equivalente dele

# um converter, ao ser ativado, deve tirar de um lugar e passar para outro
# nada fica guardado em um converter no sentido do pool, porém algumas coisas podem ficar
# temporariamente anotadas nele porque não foi completado ainda o & ou todos os recursos necessários

# um converter pode ser ativado de 3 maneiras
# por si mesmo
# quando um no que empurra empurra algo para ele
# quando um no que puxa puxa dele

# O tipo do conversor define o tipo de saida padrao
# porem o tipo do edge tem vantagem na definicao da saida
# O exemplo com 3 saidas mostra isso

  def options
    [:name]
  end







end