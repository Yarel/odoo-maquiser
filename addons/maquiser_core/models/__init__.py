from . import partner
from . import partner_category
from . import product


from odoo import api, SUPERUSER_ID

def _assign_groups(cr, registry):
    env = api.Environment(cr, SUPERUSER_ID, {})
    users = env['res.users'].search([])
    group_ventas = env.ref('maquiser_core.group_maquiser_ventas')
    users.filtered(lambda u: 'ventas' in u.login).write({'groups_id': [(4, group_ventas.id)]})
