from odoo import models, fields

class ProductTemplate(models.Model):
    _inherit = 'product.template'

    # Campos existentes
    tipo_producto_textil = fields.Selection(
        [('uniforme', 'Uniforme'), ('tela', 'Tela'), ('insumo', 'Insumo')],
        string='Tipo Producto Textil'
    )
    composicion_textil = fields.Char(string='Composición Textil')
    
    # Nuevos campos requeridos
    tipo_tela = fields.Selection(
        [('algodon', 'Algodón'), 
         ('poliéster', 'Poliéster'),
         ('mezcla', 'Mezcla')],
        string='Tipo de Tela'
    )
    gramaje = fields.Float(string='Gramaje (g/m²)')
    color_index = fields.Integer(string='Índice de Color')